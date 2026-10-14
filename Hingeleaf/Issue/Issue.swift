import Foundation

/// One Colnect catalog issue. This is the album's title: country, topic, and catalog number.
/// Role and mount are the fold, not a second record.
struct Issue: Codable, Sendable, Equatable, Identifiable {
    var id: String
    var title: String
    var country: String
    var topic: String
    var catalogNumber: String
    var year: Int?
    var barcode: String?
    var role: IssueRole
    var mountID: UUID?

    init(
        id: String,
        title: String,
        country: String,
        topic: String,
        catalogNumber: String,
        year: Int? = nil,
        barcode: String? = nil,
        role: IssueRole = .loose,
        mountID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.country = country
        self.topic = topic
        self.catalogNumber = catalogNumber
        self.year = year
        self.barcode = barcode
        self.role = role
        self.mountID = mountID
    }
}
