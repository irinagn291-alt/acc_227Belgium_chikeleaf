import Foundation
import SwiftUI

/// The only seam between the fold and storage. Views never touch UserDefaults or files.
@MainActor
final class LeafStore: ObservableObject {
    nonisolated static let chartKey = "hlf.chart.v1"
    nonisolated static let demoKey = "hlf.demo.v1"
    nonisolated static let debounceNanoseconds: UInt64 = 400_000_000

    private let defaults: UserDefaults
    private let directory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var saveTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var searchGeneration = 0

    private(set) var chart: LeafChart
    private(set) var recoveryNote: String?
    private(set) var searching = false
    private(set) var searchPage = CatalogPage(issues: [], fromShelf: false, notice: nil)
    let client: ColnectClient

    init(
        defaults: UserDefaults,
        directory: URL,
        client: ColnectClient = ColnectClient()
    ) {
        self.defaults = defaults
        self.directory = directory
        self.client = client
        decoder.keyDecodingStrategy = .useDefaultKeys
        chart = LeafChart()
    }

    func load() async {
        let loaded = await Self.readChart(
            defaults: defaults,
            key: Self.chartKey,
            directory: directory,
            decoder: decoder
        )
        objectWillChange.send()
        chart = loaded.chart
        recoveryNote = loaded.note
        seedDemoIfNeeded()
    }

    func setOnboardingComplete(_ complete: Bool) {
        objectWillChange.send()
        chart.onboardingComplete = complete
        scheduleSave()
    }

    func dismissRecovery() {
        objectWillChange.send()
        recoveryNote = nil
    }

    func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: Self.debounceNanoseconds)
            } catch {
                return
            }
            guard let self else {
                return
            }
            await self.flush()
        }
    }

    func flush() async {
        saveTask?.cancel()
        saveTask = nil
        let snapshot = chart
        let data: Data
        do {
            data = try encoder.encode(snapshot)
        } catch {
            recoveryNote = "The album could not be saved."
            return
        }
        defaults.set(data, forKey: Self.chartKey)
        do {
            try await Self.project(data, directory: directory)
        } catch {
            recoveryNote = "The album copy on disk could not be written. The leaf on screen is unchanged."
        }
    }

    func scenePhaseChanged(_ phase: ScenePhase) async {
        if phase == .inactive || phase == .background {
            await flush()
        }
    }

    func resetAllData() async {
        saveTask?.cancel()
        searchTask?.cancel()
        objectWillChange.send()
        chart = LeafChart(mounts: Self.blankMounts())
        recoveryNote = nil
        searching = false
        searchPage = CatalogPage(issues: [], fromShelf: false, notice: nil)
        defaults.removeObject(forKey: Self.chartKey)
        await Self.removeFiles(directory: directory)
    }

    func admit(_ issue: Issue) {
        objectWillChange.send()
        chart = IssueFold.admitLoose(issue, into: chart)
        scheduleSave()
    }

    func hinge(issueID: String, mountID: UUID) -> Result<Void, FoldFault> {
        switch IssueFold.hinge(issueID: issueID, mountID: mountID, chart: chart, day: AlbumDay.stamp()) {
        case let .success(next):
            objectWillChange.send()
            chart = next
            scheduleSave()
            return .success(())
        case let .failure(fault):
            return .failure(fault)
        }
    }

    func cancel(issueID: String) -> Result<Void, FoldFault> {
        switch IssueFold.cancel(issueID: issueID, chart: chart, day: AlbumDay.stamp()) {
        case let .success(next):
            objectWillChange.send()
            chart = next
            scheduleSave()
            return .success(())
        case let .failure(fault):
            return .failure(fault)
        }
    }

    func grade(issueID: String, grade: Int, note: String) -> Result<Void, FoldFault> {
        switch IssueFold.grade(issueID: issueID, grade: grade, note: note, chart: chart) {
        case let .success(next):
            objectWillChange.send()
            chart = next
            scheduleSave()
            return .success(())
        case let .failure(fault):
            return .failure(fault)
        }
    }

    func peel() -> Result<Void, FoldFault> {
        switch IssueFold.peel(chart: chart) {
        case let .success(next):
            objectWillChange.send()
            chart = next
            scheduleSave()
            return .success(())
        case let .failure(fault):
            return .failure(fault)
        }
    }

    /// Debounces about 300 ms and drops a stale response when the query changes.
    func updateSearch(terms: String) {
        searchTask?.cancel()
        searchGeneration += 1
        let generation = searchGeneration
        let trimmed = terms
        objectWillChange.send()
        searching = true
        searchTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
            } catch {
                self?.finishSearch(generation: generation)
                return
            }
            guard let self else {
                return
            }
            let page: CatalogPage
            do {
                page = try await self.client.search(terms: trimmed, page: 1)
            } catch is CancellationError {
                self.finishSearch(generation: generation)
                return
            } catch {
                page = CatalogPage(
                    issues: [],
                    fromShelf: true,
                    notice: "The catalog did not answer."
                )
            }
            guard generation == self.searchGeneration else {
                return
            }
            self.finishSearch(generation: generation)
            self.remember(page, terms: trimmed)
        }
    }

    private func finishSearch(generation: Int) {
        guard generation == searchGeneration else {
            return
        }
        objectWillChange.send()
        searching = false
    }

    func resolveScan(_ payload: String) async {
        let page: CatalogPage
        do {
            page = try await client.resolve(code: payload)
        } catch {
            page = CatalogPage(
                issues: [],
                fromShelf: true,
                notice: "The catalog did not answer. Try the code again."
            )
        }
        remember(page, terms: payload)
    }

    func remember(_ page: CatalogPage, terms: String) {
        objectWillChange.send()
        searchPage = page
        for issue in page.issues {
            if chart.issues.contains(where: { $0.id == issue.id }) {
                continue
            }
            chart.issues.append(issue)
        }
        chart.sessions.append(
            SearchSession(
                terms: terms,
                page: 1,
                issueIDs: page.issues.map(\.id),
                day: AlbumDay.stamp()
            )
        )
        scheduleSave()
    }

    private func seedDemoIfNeeded() {
        #if targetEnvironment(simulator)
        if defaults.bool(forKey: Self.demoKey) {
            return
        }
        if !chart.issues.isEmpty {
            defaults.set(true, forKey: Self.demoKey)
            return
        }
        objectWillChange.send()
        chart = Self.demoChart()
        defaults.set(true, forKey: Self.demoKey)
        scheduleSave()
        #endif
    }

    func appendLeaf() {
        objectWillChange.send()
        chart.mounts.append(contentsOf: Self.blankMounts())
        scheduleSave()
    }

    func discardLoose(issueID: String) {
        objectWillChange.send()
        chart = IssueFold.discardLoose(issueID: issueID, chart: chart)
        scheduleSave()
    }

    func presentShelf() {
        objectWillChange.send()
        let issues = BundledShelf.issues()
        searchPage = CatalogPage(issues: issues, fromShelf: true, notice: nil)
    }

    nonisolated static func blankMounts(count: Int = 12) -> [Mount] {
        (0..<count).map { _ in Mount() }
    }

    /// Two cancelled plates with grades, one hinged issue ready to cancel, one loose tray issue.
    nonisolated static func demoChart() -> LeafChart {
        let shelf = BundledShelf.issues()
        let fallback = demoShelf()
        let source = shelf.count >= 4 ? shelf : fallback
        var chart = LeafChart(mounts: blankMounts(), onboardingComplete: true)
        let seated = Array(source.prefix(4))
        chart = IssueFold.admitLoose(seated[0], into: chart)
        chart = IssueFold.admitLoose(seated[1], into: chart)
        chart = IssueFold.admitLoose(seated[2], into: chart)
        chart = IssueFold.admitLoose(seated[3], into: chart)
        let day = AlbumDay.stamp()
        if case let .success(hinged) = IssueFold.hinge(
            issueID: seated[0].id,
            mountID: chart.mounts[0].id,
            chart: chart,
            day: day
        ) {
            chart = hinged
        }
        if case let .success(cancelled) = IssueFold.cancel(issueID: seated[0].id, chart: chart, day: day) {
            chart = cancelled
        }
        if case let .success(graded) = IssueFold.grade(
            issueID: seated[0].id,
            grade: 4,
            note: "Clean hinge, light cancel.",
            chart: chart
        ) {
            chart = graded
        }
        if case let .success(hinged) = IssueFold.hinge(
            issueID: seated[1].id,
            mountID: chart.mounts[1].id,
            chart: chart,
            day: day
        ) {
            chart = hinged
        }
        if case let .success(cancelled) = IssueFold.cancel(issueID: seated[1].id, chart: chart, day: day) {
            chart = cancelled
        }
        if case let .success(graded) = IssueFold.grade(
            issueID: seated[1].id,
            grade: 2,
            note: "Short perforation.",
            chart: chart
        ) {
            chart = graded
        }
        if case let .success(hinged) = IssueFold.hinge(
            issueID: seated[2].id,
            mountID: chart.mounts[2].id,
            chart: chart,
            day: day
        ) {
            chart = hinged
        }
        return chart
    }

    private nonisolated static func demoShelf() -> [Issue] {
        [
            Issue(id: "hlf-seed-a", title: "Penny Red", country: "Great Britain", topic: "Victoria", catalogNumber: "GB 8"),
            Issue(id: "hlf-seed-b", title: "Sower", country: "France", topic: "Allegory", catalogNumber: "FR 130"),
            Issue(id: "hlf-seed-c", title: "Crane", country: "Japan", topic: "Birds", catalogNumber: "JP 214"),
            Issue(id: "hlf-seed-d", title: "Fort Bliss", country: "United States", topic: "Flags", catalogNumber: "US 899")
        ]
    }

    private struct Loaded: Sendable {
        var chart: LeafChart
        var note: String?
    }

    private static func readChart(
        defaults: UserDefaults,
        key: String,
        directory: URL,
        decoder: JSONDecoder
    ) async -> Loaded {
        if let data = defaults.data(forKey: key), let chart = decode(data, decoder: decoder) {
            return Loaded(chart: chart, note: nil)
        }
        let file = await readFiles(directory: directory)
        if let data = file.primary, let chart = decode(data, decoder: decoder) {
            return Loaded(chart: chart, note: nil)
        }
        if let data = file.backup, let chart = decode(data, decoder: decoder) {
            return Loaded(chart: chart, note: "Recovered the last good album leaf.")
        }
        if defaults.data(forKey: key) != nil || file.primary != nil {
            return Loaded(
                chart: LeafChart(mounts: blankMounts()),
                note: "The album file was unreadable. Started a blank leaf."
            )
        }
        return Loaded(chart: LeafChart(mounts: blankMounts()), note: nil)
    }

    private static func decode(_ data: Data, decoder: JSONDecoder) -> LeafChart? {
        try? decoder.decode(LeafChart.self, from: data)
    }

    /// File IO leaves the main actor. Atomic replace keeps a truncated write from launching.
    private nonisolated static func project(_ data: Data, directory: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .utility).async {
                do {
                    try blockingProject(data, directory: directory)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private nonisolated static func blockingProject(_ data: Data, directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let primary = directory.appendingPathComponent("leaf-chart.json")
        let backup = directory.appendingPathComponent("leaf-chart.json.backup")
        if FileManager.default.fileExists(atPath: primary.path) {
            if FileManager.default.fileExists(atPath: backup.path) {
                try FileManager.default.removeItem(at: backup)
            }
            try FileManager.default.copyItem(at: primary, to: backup)
        }
        try data.write(to: primary, options: .atomic)
        if FileManager.default.fileExists(atPath: backup.path) == false {
            try FileManager.default.copyItem(at: primary, to: backup)
        }
    }

    private nonisolated static func readFiles(directory: URL) async -> (primary: Data?, backup: Data?) {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                let primaryURL = directory.appendingPathComponent("leaf-chart.json")
                let backupURL = directory.appendingPathComponent("leaf-chart.json.backup")
                let primary = try? Data(contentsOf: primaryURL)
                let backup = try? Data(contentsOf: backupURL)
                continuation.resume(returning: (primary, backup))
            }
        }
    }

    private nonisolated static func removeFiles(directory: URL) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                let primary = directory.appendingPathComponent("leaf-chart.json")
                let backup = directory.appendingPathComponent("leaf-chart.json.backup")
                try? FileManager.default.removeItem(at: primary)
                try? FileManager.default.removeItem(at: backup)
                continuation.resume()
            }
        }
    }
}
