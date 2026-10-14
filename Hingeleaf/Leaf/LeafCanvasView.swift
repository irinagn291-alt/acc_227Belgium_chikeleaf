import SwiftUI
import UIKit

/// The only drawn surface. Perforations are the album mechanic. Other screens stay stock SwiftUI.
struct LeafCanvasView: UIViewRepresentable {
    var mounts: [Mount]
    var issues: [Issue]
    var grades: [String: Int] = [:]
    var cancelDays: [String: Int] = [:]
    var activeID: UUID?
    var onTap: (UUID) -> Void

    func makeUIView(context: Context) -> PerforationBoard {
        let board = PerforationBoard()
        board.onTap = onTap
        return board
    }

    func updateUIView(_ board: PerforationBoard, context: Context) {
        board.mounts = mounts
        board.issues = issues
        board.grades = grades
        board.cancelDays = cancelDays
        board.activeID = activeID
        board.onTap = onTap
        board.invalidateIntrinsicContentSize()
        board.setNeedsLayout()
        board.setNeedsDisplay()
    }
}

final class PerforationBoard: UIView {
    var mounts: [Mount] = []
    var issues: [Issue] = []
    var grades: [String: Int] = [:]
    var cancelDays: [String: Int] = [:]
    var activeID: UUID?
    var onTap: ((UUID) -> Void)?
    private var frames: [UUID: CGRect] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isAccessibilityElement = false
        contentMode = .redraw
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (board: PerforationBoard, _: UITraitCollection) in
            board.setNeedsDisplay()
        }
    }

    required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: CGSize {
        let width = bounds.width > 1 ? bounds.width : 320
        return CGSize(width: UIView.noIntrinsicMetric, height: Self.preferredHeight(mountCount: mounts.count, width: width))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        frames = Self.layout(mounts: mounts, activeID: activeID, in: bounds.insetBy(dx: AlbumSpace.m, dy: AlbumSpace.s))
        publishAccessibility()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let ink = UIColor(DesignTokens.ink)
        let muted = UIColor(DesignTokens.muted)
        let accent = UIColor(DesignTokens.accent)
        let surface = UIColor(DesignTokens.surface)
        let compact = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        for mount in mounts {
            guard let frame = frames[mount.id] else {
                continue
            }
            let active = mount.id == activeID
            let radius = active ? AlbumRadius.card : AlbumRadius.chip
            let path = UIBezierPath(roundedRect: frame, cornerRadius: radius)
            context.saveGState()
            path.addClip()
            surface.setFill()
            context.fill(frame)
            drawPerforations(in: frame, color: muted, context: context)
            let issue = issues.first { $0.id == mount.issueID }
            let title = issue?.title ?? "Open"
            let number = issue?.catalogNumber ?? ""
            let plate = Self.plate(in: frame)
            let showNumber = active && !number.isEmpty && plate.height >= AlbumSpace.unit * 6
            let titleFont = UIFont(name: AlbumType.boldFace, size: titleSize(active: active, compact: compact))
                ?? UIFont.boldSystemFont(ofSize: titleSize(active: active, compact: compact))
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byTruncatingTail
            let numberHeight = showNumber ? AlbumSpace.l : 0
            let titleRect = CGRect(
                x: plate.minX,
                y: plate.minY,
                width: plate.width,
                height: max(AlbumSpace.m, plate.height - numberHeight)
            )
            context.saveGState()
            context.clip(to: plate)
            (title as NSString).draw(
                in: titleRect,
                withAttributes: [
                    .font: titleFont,
                    .foregroundColor: ink,
                    .paragraphStyle: paragraph
                ]
            )
            if showNumber {
                let numberFont = UIFont(name: AlbumType.italicFace, size: compact ? 12 : 16)
                    ?? UIFont.italicSystemFont(ofSize: 16)
                let numberRect = CGRect(
                    x: plate.minX,
                    y: plate.maxY - numberHeight,
                    width: plate.width,
                    height: numberHeight
                )
                (number as NSString).draw(
                    in: numberRect,
                    withAttributes: [
                        .font: numberFont,
                        .foregroundColor: muted,
                        .paragraphStyle: paragraph
                    ]
                )
            }
            if let issue {
                if issue.role == .hinged {
                    drawHinge(in: frame, context: context)
                } else if issue.role == .cancelled {
                    drawCancel(
                        in: frame,
                        day: cancelDays[issue.id] ?? 0,
                        grade: grades[issue.id] ?? 0,
                        accent: accent,
                        context: context
                    )
                }
            }
            context.restoreGState()
            context.restoreGState()
            let stroke: UIColor
            if issue?.role == .cancelled {
                stroke = accent
            } else if issue?.role == .hinged {
                stroke = muted
            } else {
                stroke = active ? accent : muted
            }
            stroke.setStroke()
            if issue?.role == .hinged {
                path.setLineDash([4, 3], count: 2, phase: 0)
            }
            path.lineWidth = AlbumSpace.hairline
            path.stroke()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        let ordered = mounts.sorted { lhs, rhs in
            let left = frames[lhs.id]?.width ?? 0
            let right = frames[rhs.id]?.width ?? 0
            return left > right
        }
        for mount in ordered {
            if let frame = frames[mount.id], frame.contains(point) {
                onTap?(mount.id)
                return
            }
        }
    }

    private func drawHinge(in frame: CGRect, context: CGContext) {
        let tab = CGRect(x: frame.midX - 16, y: frame.minY + 4, width: 32, height: 12)
        UIColor(white: 0.78, alpha: 0.95).setFill()
        context.fill(tab)
        UIColor(white: 0.35, alpha: 1).setStroke()
        context.setLineWidth(1)
        context.stroke(tab)
    }

    private func drawCancel(in frame: CGRect, day: Int, grade: Int, accent: UIColor, context: CGContext) {
        let stamp = CGRect(x: frame.maxX - 52, y: frame.minY + 8, width: 44, height: 44)
        context.saveGState()
        accent.withAlphaComponent(0.85).setStroke()
        context.setLineWidth(1.5)
        context.strokeEllipse(in: stamp)
        context.move(to: CGPoint(x: stamp.minX + 6, y: stamp.midY))
        context.addQuadCurve(
            to: CGPoint(x: stamp.maxX - 6, y: stamp.midY),
            control: CGPoint(x: stamp.midX, y: stamp.midY - 6)
        )
        context.strokePath()
        let roman = ["", "I", "II", "III", "IV", "V"]
        let mark = grade >= 1 && grade <= 5 ? roman[grade] : ""
        let dayText = day > 0 ? "\(day % 100)" : ""
        let line = [mark, dayText].filter { !$0.isEmpty }.joined(separator: " ")
        let font = UIFont.boldSystemFont(ofSize: 9)
        let rect = stamp.insetBy(dx: 4, dy: 14)
        (line as NSString).draw(
            in: rect,
            withAttributes: [
                .font: font,
                .foregroundColor: accent,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.alignment = .center
                    return style
                }()
            ]
        )
        context.restoreGState()
    }

    private func titleSize(active: Bool, compact: Bool) -> CGFloat {
        if compact {
            return active ? 18 : 12
        }
        return active ? 22 : 14
    }

    /// Rim reserved for dots. Type is drawn only inside `plate`.
    static let rim: CGFloat = AlbumSpace.s

    static func plate(in frame: CGRect) -> CGRect {
        frame.insetBy(dx: AlbumSpace.s, dy: rim)
    }

    private func drawPerforations(in frame: CGRect, color: UIColor, context: CGContext) {
        color.setFill()
        let step = AlbumSpace.s + AlbumSpace.xs
        let dot = AlbumSpace.xs
        let yTop = frame.minY + (Self.rim - dot) / 2
        let yBot = frame.maxY - Self.rim + (Self.rim - dot) / 2
        context.saveGState()
        context.clip(to: frame.insetBy(dx: 0, dy: 0))
        var x = frame.minX + AlbumSpace.s
        while x < frame.maxX - AlbumSpace.s {
            let top = CGRect(x: x, y: yTop, width: dot, height: dot)
            let bottom = CGRect(x: x, y: yBot, width: dot, height: dot)
            if top.maxY <= frame.minY + Self.rim {
                context.fillEllipse(in: top)
            }
            if bottom.minY >= frame.maxY - Self.rim {
                context.fillEllipse(in: bottom)
            }
            x += step
        }
        context.restoreGState()
    }

    private func publishAccessibility() {
        var elements: [UIAccessibilityElement] = []
        for mount in mounts {
            guard let frame = frames[mount.id] else {
                continue
            }
            let element = UIAccessibilityElement(accessibilityContainer: self)
            element.accessibilityFrameInContainerSpace = frame
            if let issue = issues.first(where: { $0.id == mount.issueID }) {
                element.accessibilityLabel = "\(issue.title), \(issue.catalogNumber)"
            } else {
                element.accessibilityLabel = "Open perforation"
            }
            element.accessibilityTraits = .button
            elements.append(element)
        }
        accessibilityElements = elements
    }

    static let quietHit: CGFloat = 44
    static let heroMin: CGFloat = AlbumSpace.unit * 16

    static func preferredHeight(mountCount: Int, width: CGFloat) -> CGFloat {
        let inset = AlbumSpace.m * 2
        let inner = Self.stackHeight(quietCount: max(0, mountCount - 1), width: max(width - inset, 40))
        return inner + AlbumSpace.s * 2
    }

    private static func stackHeight(quietCount: Int, width: CGFloat) -> CGFloat {
        let gap = AlbumSpace.s
        let columns = 3
        if quietCount == 0 {
            return max(heroMin, width * 0.72)
        }
        let rows = Int(ceil(Double(quietCount) / Double(columns)))
        let grid = CGFloat(rows) * quietHit + CGFloat(rows - 1) * gap
        return heroMin + gap + grid
    }

    static func layout(mounts: [Mount], activeID: UUID?, in bounds: CGRect) -> [UUID: CGRect] {
        guard !mounts.isEmpty, bounds.width > 40, bounds.height > 40 else {
            return [:]
        }
        var map: [UUID: CGRect] = [:]
        let active = mounts.first { $0.id == activeID } ?? mounts[0]
        let rest = mounts.filter { $0.id != active.id }
        let gap = AlbumSpace.s
        let columns = 3
        if rest.isEmpty {
            map[active.id] = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.height)
            return map
        }
        let rows = Int(ceil(Double(rest.count) / Double(columns)))
        let grid = CGFloat(rows) * quietHit + CGFloat(max(0, rows - 1)) * gap
        let heroHeight = max(heroMin, bounds.height - gap - grid)
        map[active.id] = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: heroHeight)
        let top = bounds.minY + heroHeight + gap
        let cellWidth = (bounds.width - gap * CGFloat(columns - 1)) / CGFloat(columns)
        for (index, mount) in rest.enumerated() {
            let column = index % columns
            let row = index / columns
            let x = bounds.minX + CGFloat(column) * (cellWidth + gap)
            let y = top + CGFloat(row) * (quietHit + gap)
            map[mount.id] = CGRect(x: x, y: y, width: cellWidth, height: quietHit)
        }
        return map
    }
}
