import SwiftUI

/// CancelMark ledger in day order. Skew and drift stay off this list.
struct SeenView: View {
    @ObservedObject var store: LeafStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            let marks = store.chart.cancelMarks.sorted { lhs, rhs in
                if lhs.day == rhs.day {
                    return lhs.sequence < rhs.sequence
                }
                return lhs.day < rhs.day
            }
            VStack(spacing: 0) {
                AlbumBand(title: "SEEN")
                Group {
                    if let note = store.recoveryNote, marks.isEmpty {
                        AlbumEmpty(
                            title: "The ledger could not be read.",
                            line: note,
                            action: "Try the leaf again",
                            art: "hlf_EmptyList",
                            go: { store.dismissRecovery() }
                        )
                    } else if marks.isEmpty {
                        AlbumEmpty(
                            title: "No cancels on the ledger.",
                            line: "When you cancel a hinge, the day lands here.",
                            action: "Back to the leaf",
                            art: "hlf_EmptyList",
                            go: { dismiss() }
                        )
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: AlbumSpace.m) {
                                Text(AlbumCount.text(marks.count))
                                    .font(AlbumType.display(compact: false))
                                    .foregroundStyle(DesignTokens.ink)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                Text("Cancels, newest day last.")
                                    .font(AlbumType.body)
                                    .foregroundStyle(DesignTokens.muted)
                                ForEach(marks) { mark in
                                    let issue = store.chart.issues.first { $0.id == mark.issueID }
                                    VStack(alignment: .leading, spacing: AlbumSpace.xs) {
                                        Text(issue?.title ?? "Stamp")
                                            .font(AlbumType.headline)
                                            .foregroundStyle(DesignTokens.ink)
                                            .lineLimit(2)
                                        Text(AlbumCount.dayLabel(mark.day))
                                            .font(AlbumType.caption)
                                            .foregroundStyle(DesignTokens.muted)
                                        Text(issue?.catalogNumber ?? "")
                                            .font(AlbumType.catalog)
                                            .foregroundStyle(DesignTokens.ink)
                                            .lineLimit(1)
                                    }
                                    .padding(AlbumSpace.m)
                                    .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
                                    .albumPlate()
                                }
                            }
                            .padding(AlbumSpace.l)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .background(DesignTokens.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .frame(minHeight: 44)
                        .accessibilityLabel("Close seen")
                }
            }
        }
    }
}
