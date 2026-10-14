import SwiftUI

/// Three pages. Continue or Next is full width. Skip still marks the leaf ready.
struct OnboardingView: View {
    var finish: () -> Void
    @State private var page = 0

    private let pages: [(title: String, line: String, art: String)] = [
        ("Seat the next stamp.", "Search or scan a catalog number onto an empty perforation.", "hlf_Onboarding1"),
        ("Cancel the hinge.", "When the paper stamp is in hand, cancel that perforation.", "hlf_Onboarding2"),
        ("Grade only what you own.", "Taste reads country from cancelled grades.", "hlf_Onboarding3")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AlbumBand(title: "HINGELEAF")
            VStack(alignment: .leading, spacing: AlbumSpace.m) {
                Image(pages[page].art)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityHidden(true)
                Text(pages[page].title)
                    .font(AlbumType.title)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                Text(pages[page].line)
                    .font(AlbumType.body)
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Button(page == pages.count - 1 ? "Start filing" : "Continue") {
                    if page == pages.count - 1 {
                        finish()
                    } else {
                        page += 1
                    }
                }
                .buttonStyle(AlbumFill())
                Button("Skip") {
                    finish()
                }
                .font(AlbumType.caption)
                .foregroundStyle(DesignTokens.muted)
                .frame(maxWidth: .infinity, minHeight: 44)
            }
            .padding(AlbumSpace.l)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DesignTokens.bg.ignoresSafeArea())
    }
}
