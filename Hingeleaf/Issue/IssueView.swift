import SwiftUI

/// Confirms a hinge onto the active mount. A second hinge on the same issue is refused by the fold.
struct IssueView: View {
    @ObservedObject var store: LeafStore
    let issue: Issue
    let mountID: UUID?
    @Environment(\.dismiss) private var dismiss
    @State private var fault = ""
    @State private var working = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AlbumBand(title: "HINGE")
            ScrollView {
                VStack(alignment: .leading, spacing: AlbumSpace.m) {
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
                    Text(issue.topic)
                        .font(AlbumType.body)
                        .foregroundStyle(DesignTokens.ink)
                    if let year = issue.year {
                        Text(AlbumCount.year(year))
                            .font(AlbumType.caption)
                            .foregroundStyle(DesignTokens.muted)
                    }
                    VStack(alignment: .leading, spacing: AlbumSpace.s) {
                        Image("hlf_TwistHero")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 180, maxHeight: 180)
                            .frame(maxWidth: .infinity)
                            .accessibilityHidden(true)
                        Text("Hinge seats this stamp on the open spot as a want. Cancel later, when the paper is in hand.")
                            .font(AlbumType.body)
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Taste ignores it until you cancel.")
                            .font(AlbumType.caption)
                            .foregroundStyle(DesignTokens.muted)
                    }
                    .padding(AlbumSpace.m)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .albumPlate()
                    if mountID == nil {
                        Text("Pick an open spot on the page first.")
                            .font(AlbumType.caption)
                            .foregroundStyle(DesignTokens.ink)
                    }
                    if !fault.isEmpty {
                        Text(fault)
                            .font(AlbumType.caption)
                            .foregroundStyle(DesignTokens.ink)
                    }
                }
                .padding(AlbumSpace.l)
            }
        }
        .background(DesignTokens.bg)
        .safeAreaInset(edge: .bottom) {
            Button(working ? "Seating" : "Hinge") {
                seat()
            }
            .buttonStyle(AlbumFill())
            .disabled(working || mountID == nil)
            .padding(.horizontal, AlbumSpace.l)
            .padding(.vertical, AlbumSpace.m)
            .background(DesignTokens.bg)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
                    .frame(minHeight: 44)
                    .accessibilityLabel("Close hinge")
            }
        }
    }

    private func seat() {
        guard let mountID else {
            fault = "Pick an open spot on the page first."
            return
        }
        working = true
        store.admit(issue)
        let result = store.hinge(issueID: issue.id, mountID: mountID)
        working = false
        switch result {
        case .success:
            AlbumHaptic.commit()
            dismiss()
        case let .failure(error):
            fault = albumFault(error)
        }
    }
}
