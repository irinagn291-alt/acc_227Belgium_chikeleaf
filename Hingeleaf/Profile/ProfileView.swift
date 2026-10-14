import SwiftUI

/// Taste from cancelled grades only. Hinged wants never enter the country totals.
struct ProfileView: View {
    @ObservedObject var store: LeafStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            let taste = IssueFold.taste(store.chart)
            VStack(spacing: 0) {
                AlbumBand(title: "TASTE")
                Group {
                    if let note = store.recoveryNote, taste.cancelMarkCount == 0 {
                        AlbumEmpty(
                            title: "Taste could not be read.",
                            line: note,
                            action: "Try the leaf again",
                            art: "hlf_EmptyList",
                            go: { store.dismissRecovery() }
                        )
                    } else if taste.cancelMarkCount == 0 {
                        AlbumEmpty(
                            title: "No cancelled grades yet.",
                            line: "Cancel a hinge, then grade the copy. Taste counts those cancels.",
                            action: "Back to the leaf",
                            art: "hlf_EmptyList",
                            go: { dismiss() }
                        )
                    } else {
                        populated(taste)
                    }
                }
            }
            .background(DesignTokens.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .frame(minHeight: 44)
                        .accessibilityLabel("Close taste")
                }
            }
        }
    }

    private func populated(_ taste: TasteReading) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AlbumSpace.l) {
                VStack(alignment: .leading, spacing: AlbumSpace.s) {
                    Text("CANCELS")
                        .font(AlbumType.micro)
                        .foregroundStyle(DesignTokens.bg)
                        .padding(.horizontal, AlbumSpace.s)
                        .padding(.vertical, AlbumSpace.xs)
                        .background(DesignTokens.accent)
                    Text(AlbumCount.text(taste.cancelMarkCount))
                        .font(AlbumType.display(compact: false))
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text("Copies in hand, not search history.")
                    Text(String(format: "Average grade %.1f", taste.averageGrade))
                        .font(AlbumType.caption)
                        .foregroundStyle(DesignTokens.ink)
                    Text("Skew \(AlbumCount.text(taste.skewCount)). Drift \(AlbumCount.text(taste.driftCount)).")
                        .font(AlbumType.caption)
                        .foregroundStyle(DesignTokens.muted)
                        .font(AlbumType.body)
                        .foregroundStyle(DesignTokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(AlbumSpace.l)
                .frame(maxWidth: .infinity, alignment: .leading)
                .albumPlate()
                ForEach(Array(taste.countryGradeCounts.keys.sorted().enumerated()), id: \.element) { index, country in
                    let total = taste.countryGradeTotals[country] ?? 0
                    let count = taste.countryGradeCounts[country] ?? 0
                    VStack(alignment: .leading, spacing: AlbumSpace.xs) {
                        Text(country)
                            .font(index == 0 ? AlbumType.title : AlbumType.headline)
                            .foregroundStyle(DesignTokens.ink)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                        let totalText = AlbumCount.text(total)
                        let countText = AlbumCount.text(count)
                        Text("Grade total \(totalText) across \(countText)")
                            .font(AlbumType.caption)
                            .foregroundStyle(DesignTokens.muted)
                    }
                    .padding(AlbumSpace.m)
                    .frame(maxWidth: .infinity, minHeight: index == 0 ? 120 : 72, alignment: .leading)
                    .albumPlate()
                    .animation(.easeOut(duration: 0.16).delay(AlbumMotion.delay(index: index, reduceMotion: reduceMotion)), value: taste.cancelMarkCount)
                }
                if !taste.eraCounts.isEmpty {
                    VStack(alignment: .leading, spacing: AlbumSpace.s) {
                        Text("Eras")
                            .font(AlbumType.headline)
                            .foregroundStyle(DesignTokens.ink)
                        ForEach(taste.eraCounts.keys.sorted(), id: \.self) { era in
                            Text("\(era) \(AlbumCount.text(taste.eraCounts[era] ?? 0))")
                                .font(AlbumType.body)
                                .foregroundStyle(DesignTokens.ink)
                        }
                    }
                    .padding(AlbumSpace.m)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .albumPlate()
                }
                if !taste.notes.isEmpty {
                    VStack(alignment: .leading, spacing: AlbumSpace.s) {
                        Text("Notes")
                            .font(AlbumType.headline)
                            .foregroundStyle(DesignTokens.ink)
                        ForEach(taste.notes, id: \.self) { line in
                            Text(line)
                                .font(AlbumType.body)
                                .foregroundStyle(DesignTokens.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(AlbumSpace.m)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .albumPlate()
                }
            }
            .padding(AlbumSpace.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
