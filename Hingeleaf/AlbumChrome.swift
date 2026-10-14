import CoreHaptics
import SwiftUI
import UIKit

/// Spacing, radii, type, and the filled capsule. Views reach colour through DesignTokens only.
enum AlbumSpace {
    static let unit: CGFloat = 8
    static var xs: CGFloat { unit / 2 }
    static var s: CGFloat { unit }
    static var m: CGFloat { unit * 2 }
    static var l: CGFloat { unit * 3 }
    static var xl: CGFloat { unit * 4 }
    static var hairline: CGFloat { unit / 8 }
}

enum AlbumRadius {
    static var card: CGFloat { AlbumSpace.unit * 3 + AlbumSpace.xs }
    static let chip: CGFloat = 14
}

enum AlbumType {
    static let boldFace = "IowanOldStyle-Bold"
    static let romanFace = "IowanOldStyle-Roman"
    static let italicFace = "IowanOldStyle-Italic"

    static func display(compact: Bool) -> Font {
        Font.custom(boldFace, size: compact ? 28 : 40, relativeTo: .largeTitle)
    }

    static var title: Font {
        Font.custom(boldFace, size: 28, relativeTo: .title)
    }

    static var headline: Font {
        Font.custom(boldFace, size: 20, relativeTo: .headline)
    }

    static var body: Font {
        Font.custom(romanFace, size: 17, relativeTo: .body)
    }

    static var caption: Font {
        Font.custom(romanFace, size: 14, relativeTo: .caption)
    }

    static var micro: Font {
        Font.custom(romanFace, size: 12, relativeTo: .caption2)
    }

    static var catalog: Font {
        Font.custom(italicFace, size: 17, relativeTo: .body)
    }
}

enum AlbumCount {
    private static let whole: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    static func text(_ value: Int) -> String {
        whole.string(from: NSNumber(value: value)) ?? String(value)
    }

    /// Catalog years stay ungrouped. 1858 is a year, not a count.
    static func year(_ value: Int) -> String {
        String(value)
    }

    static func dayLabel(_ stamp: Int) -> String {
        let year = stamp / 10_000
        let month = (stamp / 100) % 100
        let day = stamp % 100
        var calendar = Calendar.current
        calendar.timeZone = .current
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        let date = calendar.date(from: parts) ?? Date()
        let start = calendar.startOfDay(for: date)
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: start)
    }
}

enum AlbumMotion {
    static func delay(index: Int, reduceMotion: Bool) -> Double {
        if reduceMotion {
            return 0
        }
        return min(Double(index) * 0.05, 0.16)
    }
}

enum AlbumFillKind {
    case accent
    case destructive
}

struct AlbumFill: ButtonStyle {
    var kind: AlbumFillKind = .accent
    var loading: Bool = false
    var expands: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        AlbumFillBody(configuration: configuration, kind: kind, loading: loading, expands: expands)
    }
}

private struct AlbumFillBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: AlbumFillKind
    let loading: Bool
    let expands: Bool
    @Environment(\.isEnabled) private var enabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .font(AlbumType.headline)
            .foregroundStyle(DesignTokens.bg)
            .frame(maxWidth: expands ? .infinity : nil, minHeight: 44)
            .padding(.horizontal, expands ? 0 : AlbumSpace.m)
            .padding(.vertical, AlbumSpace.s)
            .background(Capsule().fill(fill))
            .overlay {
                if loading {
                    ProgressView()
                        .tint(DesignTokens.bg)
                }
            }
            .opacity(opacity)
            .scaleEffect(configuration.isPressed && enabled && !reduceMotion ? 0.98 : 1)
            .contentShape(Capsule())
    }

    private var fill: Color {
        switch kind {
        case .accent:
            return enabled ? DesignTokens.accent : DesignTokens.muted
        case .destructive:
            return enabled ? DesignTokens.ink : DesignTokens.muted
        }
    }

    private var opacity: Double {
        if !enabled {
            return 0.45
        }
        if configuration.isPressed {
            return 0.72
        }
        return 1
    }
}

struct AlbumQuiet: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        AlbumQuietBody(configuration: configuration)
    }
}

private struct AlbumQuietBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var enabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .font(AlbumType.headline)
            .foregroundStyle(enabled ? DesignTokens.ink : DesignTokens.muted)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, AlbumSpace.s)
            .background(Capsule().fill(DesignTokens.surface))
            .overlay(Capsule().stroke(DesignTokens.muted, lineWidth: AlbumSpace.hairline))
            .opacity(enabled ? (configuration.isPressed ? 0.72 : 1) : 0.45)
            .scaleEffect(configuration.isPressed && enabled && !reduceMotion ? 0.98 : 1)
            .contentShape(Capsule())
    }
}

struct AlbumPress: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        AlbumPressBody(configuration: configuration)
    }
}

private struct AlbumPressBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .contentShape(Rectangle())
    }
}

struct AlbumBand: View {
    let title: String
    var decor: Bool = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(alignment: .center, spacing: AlbumSpace.m) {
            Text(title)
                .font(AlbumType.display(compact: dynamicTypeSize.isAccessibilitySize))
                .foregroundStyle(DesignTokens.bg)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
            if decor {
                Image("hlf_HeaderDecor")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 120, maxHeight: 48)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, AlbumSpace.l)
        .padding(.vertical, AlbumSpace.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.accent.ignoresSafeArea(edges: .top))
    }
}

struct AlbumHairline: ViewModifier {
    var radius: CGFloat = AlbumRadius.card

    func body(content: Content) -> some View {
        content
            .background(DesignTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(DesignTokens.muted, lineWidth: AlbumSpace.hairline)
            )
    }
}

extension View {
    func albumPlate(radius: CGFloat = AlbumRadius.card) -> some View {
        modifier(AlbumHairline(radius: radius))
    }
}

struct AlbumEmpty: View {
    let title: String
    let line: String
    let action: String
    var art: String = "hlf_EmptyHome"
    let go: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AlbumSpace.m) {
            Image(art)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 240)
                .accessibilityHidden(true)
            Text(title)
                .font(AlbumType.title)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(line)
                .font(AlbumType.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: AlbumSpace.l)
            Button(action, action: go)
                .buttonStyle(AlbumFill())
        }
        .padding(AlbumSpace.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.bg)
    }
}

@MainActor
enum AlbumHaptic {
    static let defaultsKey = "hlf.haptics"

    enum Kind {
        case hinge
        case cancel
        case peel
    }

    static var enabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: defaultsKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: defaultsKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: defaultsKey) }
    }

    private static var engine: CHHapticEngine?

    static func commit(_ kind: Kind = .cancel) {
        guard enabled, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            if engine == nil {
                engine = try CHHapticEngine()
                try engine?.start()
            }
            let intensity: Float
            let sharpness: Float
            switch kind {
            case .hinge:
                intensity = 0.4
                sharpness = 0.25
            case .cancel:
                intensity = 0.9
                sharpness = 0.85
            case .peel:
                intensity = 0.5
                sharpness = 0.7
            }
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            engine = nil
        }
    }
}

func albumFault(_ fault: FoldFault) -> String {
    switch fault {
    case .issueMissing:
        return "That stamp is not on the leaf."
    case .mountMissing:
        return "Pick a perforation first."
    case .mountOccupied:
        return "That perforation already holds a stamp."
    case .secondHinge:
        return "This stamp already has a hinge."
    case .notLoose:
        return "Only a loose stamp can take a hinge."
    case .alreadyCancelled:
        return "This copy is already cancelled."
    case .gradeOutOfRange:
        return "Grade from 1 to 5."
    case .gradeNeedsCancelled:
        return "Grade only after you cancel the hinge."
    case .nothingToPeel:
        return "Nothing left to peel."
    }
}
