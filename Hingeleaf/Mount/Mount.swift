import Foundation

/// One perforation on the leaf. Empty until a HingeMark seats an issue.
struct Mount: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var issueID: String?

    init(id: UUID = UUID(), issueID: String? = nil) {
        self.id = id
        self.issueID = issueID
    }
}
