import Foundation

/// Written when Cancel is tapped on a Loose issue. The issue stays Loose.
struct SkewMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var issueID: String
    var day: Int
    var sequence: Int

    init(id: UUID = UUID(), issueID: String, day: Int, sequence: Int) {
        self.id = id
        self.issueID = issueID
        self.day = day
        self.sequence = sequence
    }
}
