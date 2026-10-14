import SwiftUI

/// Hinged wants only. Cancelled plates and loose tray stamps stay off this list.
struct WantsView: View {
    @ObservedObject var store: LeafStore
    var onFind: () -> Void
    var onSeat: (Issue) -> Void = { _ in }
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AlbumBand(title: "WANTS")
                let wants = IssueFold.wants(store.chart)
                Group {
                    if let note = store.recoveryNote, wants.isEmpty {
                        AlbumEmpty(
                            title: "The wants could not be read.",
                            line: note,
                            action: "Try the leaf again",
                            art: "hlf_EmptyList",
                            go: { store.dismissRecovery() }
                        )
                    } else if wants.isEmpty {
                        AlbumEmpty(
                            title: "No hinged wants yet.",
                            line: "Search a country or a catalog number, then hinge it. It stays here until you cancel.",
                            action: "Find a stamp",
                            art: "hlf_EmptyList",
                            go: onFind
                        )
                    } else {
                        populated(wants)
                    }
                }
            }
            .background(DesignTokens.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .frame(minHeight: 44)
                        .accessibilityLabel("Close wants")
                }
            }
        }
    }

    private func populated(_ wants: [Issue]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AlbumSpace.l) {
                if let hero = wants.first {
                    Button {
                        onSeat(hero)
                    } label: {
                        WantsLedger(issue: hero, day: store.chart.hingeMarks.first { $0.issueID == hero.id }?.day, reduceMotion: reduceMotion)
                    }
                    .buttonStyle(AlbumPress())
                    .accessibilityLabel("Open \(hero.title) on the leaf")
                }
                HStack(spacing: AlbumSpace.m) {
                    stat("Hinged", AlbumCount.text(wants.count))
                    stat("Still loose", AlbumCount.text(IssueFold.looseTray(store.chart).count))
                }
                ForEach(Array(wants.dropFirst().enumerated()), id: \.element.id) { index, issue in
                    wantCard(issue, oversized: false, index: index + 1)
                }
            }
            .padding(AlbumSpace.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: AlbumSpace.xs) {
            Text(label)
                .font(AlbumType.caption)
                .foregroundStyle(DesignTokens.muted)
            Text(value)
                .font(AlbumType.title)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(AlbumSpace.m)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .albumPlate()
    }

    private func wantCard(_ issue: Issue, oversized: Bool, index: Int) -> some View {
        let day = store.chart.hingeMarks.first { $0.issueID == issue.id }?.day
        return VStack(alignment: .leading, spacing: AlbumSpace.s) {
            Text(issue.country.uppercased())
                .font(AlbumType.micro)
                .foregroundStyle(DesignTokens.bg)
                .lineLimit(1)
                .padding(.horizontal, AlbumSpace.s)
                .padding(.vertical, AlbumSpace.xs)
                .background(DesignTokens.accent)
            Text(issue.title)
                .font(oversized ? AlbumType.title : AlbumType.headline)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
            Text(issue.catalogNumber)
                .font(AlbumType.catalog)
                .foregroundStyle(DesignTokens.muted)
                .lineLimit(1)
            Text(issue.topic)
                .font(AlbumType.body)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
            if let day {
                Text(AlbumCount.dayLabel(day))
                    .font(AlbumType.caption)
                    .foregroundStyle(DesignTokens.muted)
            }
            Text("Still a want. Cancel it when the paper arrives.")
                .font(AlbumType.caption)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AlbumSpace.m)
        .frame(maxWidth: .infinity, minHeight: oversized ? 220 : 120, alignment: .leading)
        .albumPlate()
        .onTapGesture { onSeat(issue) }
        .opacity(1)
        .animation(.easeOut(duration: 0.16).delay(AlbumMotion.delay(index: index, reduceMotion: reduceMotion)), value: issue.id)
    }
}

/// The hinged want the log opens on. Later wants sit under it.
struct WantsLedger: View {
    let issue: Issue
    var day: Int?
    var reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AlbumSpace.s) {
            Text(issue.country.uppercased())
                .font(AlbumType.micro)
                .foregroundStyle(DesignTokens.bg)
                .lineLimit(1)
                .padding(.horizontal, AlbumSpace.s)
                .padding(.vertical, AlbumSpace.xs)
                .background(DesignTokens.accent)
            Text(issue.title)
                .font(AlbumType.title)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
            Text(issue.catalogNumber)
                .font(AlbumType.catalog)
                .foregroundStyle(DesignTokens.muted)
                .lineLimit(1)
            Text(issue.topic)
                .font(AlbumType.body)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
            if let day {
                Text(AlbumCount.dayLabel(day))
                    .font(AlbumType.caption)
                    .foregroundStyle(DesignTokens.muted)
            }
            Text("Still a want. Cancel it when the paper arrives.")
                .font(AlbumType.caption)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AlbumSpace.m)
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .leading)
        .albumPlate()
        .animation(.easeOut(duration: 0.16).delay(AlbumMotion.delay(index: 0, reduceMotion: reduceMotion)), value: issue.id)
    }
}
