import SwiftUI

/// Owned copy wall. Only cancelled stamps, one hero and quieter rows after it.
struct CrateView: View {
    @ObservedObject var store: LeafStore
    var onFind: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AlbumBand(title: "CRATE")
                let plates = IssueFold.crate(store.chart)
                Group {
                    if let note = store.recoveryNote, plates.isEmpty {
                        AlbumEmpty(
                            title: "The crate could not be read.",
                            line: note,
                            action: "Try the leaf again",
                            art: "hlf_EmptyList",
                            go: { store.dismissRecovery() }
                        )
                    } else if plates.isEmpty {
                        AlbumEmpty(
                            title: "The crate is empty.",
                            line: "Cancel a hinge and the copy lands here.",
                            action: "Find a stamp",
                            art: "hlf_EmptyList",
                            go: onFind
                        )
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: AlbumSpace.m) {
                                if let hero = plates.first {
                                    plate(hero, oversized: true)
                                }
                                ForEach(plates.dropFirst()) { issue in
                                    plate(issue, oversized: false)
                                }
                            }
                            .padding(AlbumSpace.l)
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
                        .accessibilityLabel("Close crate")
                }
            }
        }
    }

    private func plate(_ issue: Issue, oversized: Bool) -> some View {
        let grade = store.chart.plates.first { $0.issueID == issue.id }
        return VStack(alignment: .leading, spacing: AlbumSpace.s) {
            if oversized {
                Image("hlf_CardBackdrop")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: AlbumRadius.chip, style: .continuous))
                    .accessibilityHidden(true)
            }
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
            if let grade {
                let gradeText = AlbumCount.text(grade.grade)
                Text("Grade \(gradeText)")
                    .font(AlbumType.body)
                    .foregroundStyle(DesignTokens.ink)
                if !grade.note.isEmpty {
                    Text(grade.note)
                        .font(AlbumType.caption)
                        .foregroundStyle(DesignTokens.muted)
                        .lineLimit(3)
                }
            }
            Text(oversized ? "Owned and graded." : "In the crate.")
                .font(AlbumType.caption)
                .foregroundStyle(DesignTokens.ink)
        }
        .padding(AlbumSpace.m)
        .frame(maxWidth: .infinity, minHeight: oversized ? 220 : 96, alignment: .leading)
        .albumPlate()
    }
}
