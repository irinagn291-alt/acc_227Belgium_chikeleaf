import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #FFFFFF
    static let bg = Color(red: 1.000000, green: 1.000000, blue: 1.000000)
    static let bgHex = "#FFFFFF"
    /// #FFFFFF
    static let surface = Color(red: 1.000000, green: 1.000000, blue: 1.000000)
    static let surfaceHex = "#FFFFFF"
    /// #000000
    static let ink = Color(red: 0.000000, green: 0.000000, blue: 0.000000)
    static let inkHex = "#000000"
    /// #E60000
    static let accent = Color(red: 0.901961, green: 0.000000, blue: 0.000000)
    static let accentHex = "#E60000"
    /// #6B6B6B
    static let muted = Color(red: 0.419608, green: 0.419608, blue: 0.419608)
    static let mutedHex = "#6B6B6B"
    static let fontFamily = "Iowan Old Style"
}
