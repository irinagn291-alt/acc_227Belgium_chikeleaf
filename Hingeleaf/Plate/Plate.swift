import Foundation

/// Grade and local note fused only onto a Cancelled issue. This is the crate plate.
struct Plate: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var issueID: String
    var grade: Int
    var note: String

    init(id: UUID = UUID(), issueID: String, grade: Int, note: String) {
        self.id = id
        self.issueID = issueID
        self.grade = grade
        self.note = note
    }
}
