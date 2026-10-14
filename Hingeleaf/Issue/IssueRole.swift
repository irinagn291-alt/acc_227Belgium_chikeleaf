import Foundation

/// Three-case fold for one catalog issue. Loose sits in the tray, Hinged
/// occupies a mount, Cancelled is a verified plate. Profile never reads Loose or Hinged.
enum IssueRole: String, Codable, Sendable, Equatable {
    case loose
    case hinged
    case cancelled
}
