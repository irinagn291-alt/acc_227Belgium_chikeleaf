import XCTest
@testable import Hingeleaf

/// Domain, fold, catalog, and chart persistence. One external catalog, rate and local notes.
@MainActor
final class HingeleafTests: XCTestCase {
    private var suite = ""
    private var defaults = UserDefaults.standard
    private var directory = URL(fileURLWithPath: NSTemporaryDirectory())

    override func setUp() {
        super.setUp()
        suite = "hlf.tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite) ?? UserDefaults.standard
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("hlf-\(UUID().uuidString)", isDirectory: true)
        defaults.set(true, forKey: LeafStore.demoKey)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suite)
        try? FileManager.default.removeItem(at: directory)
        super.tearDown()
    }

    func test_familyInvariant_oneCatalogRateAndNotes() {
        let chart = seatedCancelled()
        let taste = IssueFold.taste(chart)
        XCTAssertEqual(taste.cancelMarkCount, 1)
        XCTAssertEqual(taste.notes, ["In-hand note"])
        XCTAssertEqual(taste.countryGradeTotals["Japan"], 5)
        XCTAssertTrue(IssueFold.wants(chart).isEmpty)
    }

    func test_emptyLeafWritesBlank() {
        let chart = LeafChart(mounts: LeafStore.blankMounts())
        XCTAssertEqual(IssueFold.surface(chart), .blank)
        XCTAssertEqual(IssueFold.hinge(issueID: "missing", mountID: UUID(), chart: chart, day: 20260927), .failure(.issueMissing))
    }

    func test_hingeFoldsLooseAndRefusesASecondHinge() {
        var chart = LeafChart(mounts: [Mount(id: mountA), Mount(id: mountB)])
        chart = IssueFold.admitLoose(sample, into: chart)
        let hinged = IssueFold.hinge(issueID: sample.id, mountID: mountA, chart: chart, day: 20260927)
        guard case let .success(next) = hinged else {
            return XCTFail("Expected a hinge")
        }
        XCTAssertEqual(next.issues[0].role, .hinged)
        XCTAssertEqual(next.mounts[0].issueID, sample.id)
        XCTAssertEqual(next.hingeMarks.count, 1)
        XCTAssertEqual(
            IssueFold.hinge(issueID: sample.id, mountID: mountB, chart: next, day: 20260927),
            .failure(.secondHinge)
        )
    }

    func test_cancelOnLooseWritesSkewAndKeepsLoose() {
        var chart = LeafChart(mounts: LeafStore.blankMounts())
        chart = IssueFold.admitLoose(sample, into: chart)
        let result = IssueFold.cancel(issueID: sample.id, chart: chart, day: 20260927)
        guard case let .success(next) = result else {
            return XCTFail("Expected skew")
        }
        XCTAssertEqual(next.issues[0].role, .loose)
        XCTAssertEqual(next.skewMarks.count, 1)
        XCTAssertTrue(next.cancelMarks.isEmpty)
    }

    func test_cancelWithoutHingeMarkWritesDrift() {
        var chart = LeafChart(mounts: LeafStore.blankMounts())
        var issue = sample
        issue.role = .hinged
        chart.issues = [issue]
        let result = IssueFold.cancel(issueID: issue.id, chart: chart, day: 20260927)
        guard case let .success(next) = result else {
            return XCTFail("Expected drift")
        }
        XCTAssertEqual(next.issues[0].role, .hinged)
        XCTAssertEqual(next.driftMarks.count, 1)
        XCTAssertEqual(IssueFold.taste(next).cancelMarkCount, 0)
    }

    func test_cancelThenGradeOnlyOnCancelledAndPeel() {
        var chart = LeafChart(mounts: [Mount(id: mountA)])
        chart = IssueFold.admitLoose(sample, into: chart)
        guard case let .success(hinged) = IssueFold.hinge(issueID: sample.id, mountID: mountA, chart: chart, day: 20260927) else {
            return XCTFail("Hinge")
        }
        XCTAssertEqual(
            IssueFold.grade(issueID: sample.id, grade: 3, note: "Soon", chart: hinged),
            .failure(.gradeNeedsCancelled)
        )
        XCTAssertTrue(IssueFold.cancelEnabled(issueID: sample.id, chart: hinged))
        guard case let .success(cancelled) = IssueFold.cancel(issueID: sample.id, chart: hinged, day: 20260927) else {
            return XCTFail("Cancel")
        }
        XCTAssertEqual(cancelled.issues[0].role, .cancelled)
        XCTAssertEqual(
            IssueFold.grade(issueID: sample.id, grade: 9, note: "No", chart: cancelled),
            .failure(.gradeOutOfRange)
        )
        guard case let .success(graded) = IssueFold.grade(issueID: sample.id, grade: 5, note: "In-hand note", chart: cancelled) else {
            return XCTFail("Grade")
        }
        let taste = IssueFold.taste(graded)
        XCTAssertEqual(taste.cancelMarkCount, 1)
        XCTAssertEqual(taste.countryGradeTotals["Japan"], 5)
        guard case let .success(peeled) = IssueFold.peel(chart: graded) else {
            return XCTFail("Peel")
        }
        XCTAssertEqual(peeled.issues[0].role, .hinged)
        XCTAssertTrue(peeled.plates.isEmpty)
        XCTAssertTrue(peeled.cancelMarks.isEmpty)
        XCTAssertEqual(IssueFold.taste(peeled).cancelMarkCount, 0)
    }

    func test_hingedWantsStayOutOfTaste() {
        var chart = LeafChart(mounts: [Mount(id: mountA)])
        chart = IssueFold.admitLoose(sample, into: chart)
        guard case let .success(hinged) = IssueFold.hinge(issueID: sample.id, mountID: mountA, chart: chart, day: 20260927) else {
            return XCTFail("Hinge")
        }
        XCTAssertEqual(IssueFold.wants(hinged).map(\.id), [sample.id])
        XCTAssertEqual(IssueFold.taste(hinged).cancelMarkCount, 0)
        XCTAssertTrue(IssueFold.taste(hinged).countryGradeTotals.isEmpty)
    }

    func test_chartRoundTripAndCorruptBackup() async {
        let store = LeafStore(defaults: defaults, directory: directory, client: ColnectClient(shelf: []))
        await store.load()
        _ = store.hinge(issueID: "none", mountID: UUID())
        store.admit(sample)
        let mount = store.chart.mounts[0].id
        let hinged = store.hinge(issueID: sample.id, mountID: mount)
        guard case .success = hinged else {
            return XCTFail("Hinge did not seat")
        }
        await store.flush()

        let reloaded = LeafStore(defaults: defaults, directory: directory, client: ColnectClient(shelf: []))
        await reloaded.load()
        XCTAssertEqual(reloaded.chart.issues.first?.role, .hinged)
        XCTAssertEqual(reloaded.chart.hingeMarks.count, 1)

        defaults.set(Data("not-json".utf8), forKey: LeafStore.chartKey)
        let primary = directory.appendingPathComponent("leaf-chart.json")
        try? Data("broken".utf8).write(to: primary, options: .atomic)
        let recovered = LeafStore(defaults: defaults, directory: directory, client: ColnectClient(shelf: []))
        await recovered.load()
        XCTAssertEqual(recovered.chart.hingeMarks.count, 1)
        XCTAssertEqual(recovered.recoveryNote, "Recovered the last good album leaf.")

        await recovered.resetAllData()
        XCTAssertNil(defaults.data(forKey: LeafStore.chartKey))
        XCTAssertTrue(recovered.chart.issues.isEmpty)
    }

    func test_reviewLaunchParsesArguments() {
        XCTAssertEqual(ReviewLaunch.screen(in: ["Hingeleaf", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Hingeleaf", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Hingeleaf", "-ReviewScreen", "goals"]), "goals")
        XCTAssertNil(ReviewLaunch.screen(in: ["Hingeleaf"]))
    }

    func test_barcodeRunsAndUpcPad() {
        XCTAssertEqual(BarcodeRun.candidates(in: "https://shop.example/p/5012345678901"), ["5012345678901"])
        XCTAssertEqual(BarcodeRun.candidates(in: "012345678905"), ["0012345678905", "012345678905"])
    }

    func test_catalogDecodesStringYearRetriesThenShelf() async throws {
        let payload = Data("""
        {"status":1,"stamps":[{"id":"c1","title":"Crane","country":"Japan","topic":"Birds","catalogNumber":"JP 1","year":"1949"}]}
        """.utf8)
        let transport = ScriptedTransport(steps: [
            .failure(URLError(.timedOut)),
            .success(payload, status: 200)
        ])
        let client = ColnectClient(transport: transport.catalog, shelf: [sample])
        let page = try await client.search(terms: "Crane", page: 1)
        XCTAssertFalse(page.fromShelf)
        XCTAssertEqual(page.issues.first?.year, 1949)
        XCTAssertEqual(transport.attempts, 2)
    }

    func test_catalog404DoesNotRetryAndStatusZeroIsNotFoundShelf() async throws {
        let missing = Data("""
        {"status":0,"stamps":[]}
        """.utf8)
        let notFound = ScriptedTransport(steps: [.success(Data("{}".utf8), status: 404)])
        let client = ColnectClient(transport: notFound.catalog, shelf: [sample])
        let page = try await client.search(terms: "Japan", page: 1)
        XCTAssertTrue(page.fromShelf)
        XCTAssertEqual(notFound.attempts, 1)
        XCTAssertEqual(page.issues.first?.id, sample.id)

        let statusZero = ScriptedTransport(steps: [.success(missing, status: 200)])
        let other = ColnectClient(transport: statusZero.catalog, shelf: [sample])
        let fallback = try await other.search(terms: "nope", page: 1)
        XCTAssertTrue(fallback.fromShelf)
        XCTAssertTrue(fallback.issues.isEmpty)
    }

    func test_albumDayUsesStartOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let day = AlbumDay.stamp(date, calendar: calendar)
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let expected = (parts.year ?? 0) * 10_000 + (parts.month ?? 0) * 100 + (parts.day ?? 0)
        XCTAssertEqual(day, expected)
    }

    func test_demoChartSeatsCancelPath() {
        let chart = LeafStore.demoChart()
        XCTAssertTrue(chart.onboardingComplete)
        XCTAssertEqual(chart.plates.count, 2)
        XCTAssertEqual(IssueFold.crate(chart).count, 2)
        let hinged = IssueFold.wants(chart)
        XCTAssertEqual(hinged.count, 1)
        XCTAssertTrue(IssueFold.cancelEnabled(issueID: hinged[0].id, chart: chart))
        XCTAssertEqual(IssueFold.looseTray(chart).count, 1)
    }

    private let mountA = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE") ?? UUID()
    private let mountB = UUID(uuidString: "BBBBBBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF") ?? UUID()
    private let sample = Issue(
        id: "hlf-jp-crane",
        title: "Crane",
        country: "Japan",
        topic: "Birds",
        catalogNumber: "JP 214"
    )

    private func seatedCancelled() -> LeafChart {
        var chart = LeafChart(mounts: [Mount(id: mountA)])
        chart = IssueFold.admitLoose(sample, into: chart)
        guard
            case let .success(hinged) = IssueFold.hinge(issueID: sample.id, mountID: mountA, chart: chart, day: 20260927),
            case let .success(cancelled) = IssueFold.cancel(issueID: sample.id, chart: hinged, day: 20260927),
            case let .success(graded) = IssueFold.grade(issueID: sample.id, grade: 5, note: "In-hand note", chart: cancelled)
        else {
            return chart
        }
        return graded
    }
}

/// NSLock serializes the scripted steps. That lock is the sendable guarantee.
private final class ScriptedTransport: @unchecked Sendable {
    enum Step {
        case success(Data, status: Int)
        case failure(URLError)
    }

    private let lock = NSLock()
    private var steps: [Step]
    private(set) var attempts = 0

    init(steps: [Step]) {
        self.steps = steps
    }

    var catalog: CatalogTransport {
        CatalogTransport { [weak self] _ in
            guard let self else {
                throw CatalogFault.transport
            }
            return try self.next()
        }
    }

    private func next() throws -> (Data, HTTPURLResponse) {
        lock.lock()
        attempts += 1
        let step = steps.isEmpty ? nil : steps.removeFirst()
        lock.unlock()
        guard let step else {
            throw CatalogFault.transport
        }
        switch step {
        case let .success(data, status):
            let url = URL(string: "https://colnect.com/en/stamps/list") ?? URL(fileURLWithPath: "/tmp/list")
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: status,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw CatalogFault.transport
            }
            return (data, response)
        case let .failure(error):
            throw error
        }
    }
}
