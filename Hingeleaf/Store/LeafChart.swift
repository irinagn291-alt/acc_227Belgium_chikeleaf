import Foundation

/// Single chart root. Mounts, issues, search sessions, hinge runs, and the four marks
/// are this album's reading of one stored record. Taste is computed, never stored.
struct LeafChart: Codable, Sendable, Equatable {
    var schemaVersion: Int
    var mounts: [Mount]
    var issues: [Issue]
    var sessions: [SearchSession]
    var hingeMarks: [HingeMark]
    var cancelMarks: [CancelMark]
    var skewMarks: [SkewMark]
    var driftMarks: [DriftMark]
    var plates: [Plate]
    var onboardingComplete: Bool
    var nextSequence: Int

    static let currentSchema = 1

    init(
        schemaVersion: Int = LeafChart.currentSchema,
        mounts: [Mount] = [],
        issues: [Issue] = [],
        sessions: [SearchSession] = [],
        hingeMarks: [HingeMark] = [],
        cancelMarks: [CancelMark] = [],
        skewMarks: [SkewMark] = [],
        driftMarks: [DriftMark] = [],
        plates: [Plate] = [],
        onboardingComplete: Bool = false,
        nextSequence: Int = 1
    ) {
        self.schemaVersion = schemaVersion
        self.mounts = mounts
        self.issues = issues
        self.sessions = sessions
        self.hingeMarks = hingeMarks
        self.cancelMarks = cancelMarks
        self.skewMarks = skewMarks
        self.driftMarks = driftMarks
        self.plates = plates
        self.onboardingComplete = onboardingComplete
        self.nextSequence = nextSequence
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case mounts
        case issues
        case sessions
        case hingeMarks
        case cancelMarks
        case skewMarks
        case driftMarks
        case plates
        case onboardingComplete
        case nextSequence
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            mounts = try container.decodeIfPresent([Mount].self, forKey: .mounts) ?? []
            issues = try container.decodeIfPresent([Issue].self, forKey: .issues) ?? []
            sessions = try container.decodeIfPresent([SearchSession].self, forKey: .sessions) ?? []
            hingeMarks = try container.decodeIfPresent([HingeMark].self, forKey: .hingeMarks) ?? []
            cancelMarks = try container.decodeIfPresent([CancelMark].self, forKey: .cancelMarks) ?? []
            skewMarks = try container.decodeIfPresent([SkewMark].self, forKey: .skewMarks) ?? []
            driftMarks = try container.decodeIfPresent([DriftMark].self, forKey: .driftMarks) ?? []
            plates = try container.decodeIfPresent([Plate].self, forKey: .plates) ?? []
            onboardingComplete = try container.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
            nextSequence = try container.decodeIfPresent(Int.self, forKey: .nextSequence) ?? 1
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported leaf schema \(version)."
            )
        }
    }
}

/// Cached search page. Islands of the chart: the query, not a second store.
struct SearchSession: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var terms: String
    var page: Int
    var issueIDs: [String]
    var day: Int

    init(id: UUID = UUID(), terms: String, page: Int, issueIDs: [String], day: Int) {
        self.id = id
        self.terms = terms
        self.page = page
        self.issueIDs = issueIDs
        self.day = day
    }
}

/// YYYYMMDD from Calendar.current.startOfDay. Stored days are integers, not timestamps.
enum AlbumDay {
    static func stamp(_ date: Date = Date(), calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }
}
