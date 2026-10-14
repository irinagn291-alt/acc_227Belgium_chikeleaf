import Foundation

/// Written when Hinge folds Loose onto an empty mount. A second hinge on the same issue is refused.
struct HingeMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var issueID: String
    var mountID: UUID
    var day: Int
    var sequence: Int

    init(id: UUID = UUID(), issueID: String, mountID: UUID, day: Int, sequence: Int) {
        self.id = id
        self.issueID = issueID
        self.mountID = mountID
        self.day = day
        self.sequence = sequence
    }
}
