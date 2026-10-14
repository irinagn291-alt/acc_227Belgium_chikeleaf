import Foundation

/// Written when Cancel hits a Hinged issue that has no seated HingeMark. Role stays Hinged.
struct DriftMark: Codable, Sendable, Equatable, Identifiable {
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
