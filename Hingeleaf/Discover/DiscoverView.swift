import SwiftUI

/// Catalog wall. Search or scan writes Loose. One oversized result, quieter tiles beside it.
struct DiscoverView: View {
    @ObservedObject var store: LeafStore
    var mountID: UUID?
    var onScan: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var termsFocus: Bool
    @State private var terms = ""
    @State private var showShelf = false
    @State private var pickedID: String?
    @State private var revealSpinner = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AlbumBand(title: "DISCOVER")
                Group {
                    if store.searching && store.searchPage.issues.isEmpty && !showShelf {
                        placeholder
                    } else if isError && !showShelf {
                        errorPage
                    } else if store.searchPage.issues.isEmpty {
                        AlbumEmpty(
                            title: "The crate is empty.",
                            line: "Type a country, a topic, or a catalog number.",
                            action: "Scan a pack",
                            art: "hlf_EmptyList",
                            go: onScan
                        )
                    } else {
                        wall
                    }
                }
            }
            .background(DesignTokens.bg)
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .frame(minHeight: 44)
                        .accessibilityLabel("Close discover")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { termsFocus = false }
                }
            }
            .navigationDestination(item: $pickedID) { id in
                if let issue = store.searchPage.issues.first(where: { $0.id == id })
                    ?? store.chart.issues.first(where: { $0.id == id }) {
                    IssueView(store: store, issue: issue, mountID: mountID)
                }
            }
            .safeAreaInset(edge: .top) {
                VStack(spacing: AlbumSpace.s) {
                    TextField("Country, topic, or number", text: $terms)
                        .font(AlbumType.body)
                        .foregroundStyle(DesignTokens.ink)
                        .padding(AlbumSpace.s)
                        .albumPlate(radius: AlbumRadius.chip)
                        .focused($termsFocus)
                        .submitLabel(.search)
                        .onSubmit { runSearch() }
                    Button(store.searching ? "Searching" : "Search") { runSearch() }
                        .buttonStyle(AlbumFill(loading: revealSpinner))
                        .disabled(store.searching || terms.trimmingCharacters(in: .whitespaces).isEmpty)
                    Button("Scan") { onScan() }
                        .buttonStyle(AlbumQuiet())
                }
                .padding(.horizontal, AlbumSpace.l)
                .padding(.vertical, AlbumSpace.m)
                .background(DesignTokens.bg)
            }
            .onChange(of: store.searching) { _, searching in
                if searching {
                    revealSpinner = false
                    Task {
                        try? await Task.sleep(nanoseconds: 150_000_000)
                        if store.searching {
                            revealSpinner = true
                        }
                    }
                } else {
                    revealSpinner = false
                }
            }
        }
    }

    private var isError: Bool {
        let notice = store.searchPage.notice ?? ""
        return store.searchPage.issues.isEmpty && !notice.isEmpty
    }

    private var errorPage: some View {
        VStack(alignment: .leading, spacing: AlbumSpace.m) {
            Image("hlf_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 200)
                .accessibilityHidden(true)
            Text("The catalog did not answer.")
                .font(AlbumType.title)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(store.searchPage.notice ?? "Try the search again, or read the saved shelf.")
                .font(AlbumType.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: AlbumSpace.l)
            Button("Search again") { runSearch() }
                .buttonStyle(AlbumFill())
            Button("Show the shelf") {
                showShelf = true
                store.presentShelf()
            }
                .buttonStyle(AlbumQuiet())
        }
        .padding(AlbumSpace.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var placeholder: some View {
        VStack(alignment: .leading, spacing: AlbumSpace.m) {
            RoundedRectangle(cornerRadius: AlbumRadius.card, style: .continuous)
                .fill(DesignTokens.surface)
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .overlay(RoundedRectangle(cornerRadius: AlbumRadius.card, style: .continuous).stroke(DesignTokens.muted, lineWidth: AlbumSpace.hairline))
                .redacted(reason: reduceMotion ? [] : .placeholder)
            if revealSpinner {
                ProgressView()
                    .tint(DesignTokens.accent)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            Spacer(minLength: 0)
        }
        .padding(AlbumSpace.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityLabel("Searching the catalog")
    }

    private var wall: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AlbumSpace.m) {
                if let notice = store.searchPage.notice, !notice.isEmpty {
                    Text(notice)
                        .font(AlbumType.caption)
                        .foregroundStyle(DesignTokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let hero = store.searchPage.issues.first {
                    DiscoverWall(issue: hero, reduceMotion: reduceMotion) {
                        pickedID = hero.id
                    }
                }
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: AlbumSpace.s),
                        GridItem(.flexible(), spacing: AlbumSpace.s)
                    ],
                    spacing: AlbumSpace.s
                ) {
                    ForEach(Array(store.searchPage.issues.dropFirst().enumerated()), id: \.element.id) { index, issue in
                        issueButton(issue, oversized: false, index: index + 1)
                    }
                }
            }
            .padding(AlbumSpace.l)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func issueButton(_ issue: Issue, oversized: Bool, index: Int) -> some View {
        Button {
            pickedID = issue.id
        } label: {
            VStack(alignment: .leading, spacing: AlbumSpace.s) {
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
                    .font(AlbumType.caption)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
            }
            .padding(AlbumSpace.m)
            .frame(maxWidth: .infinity, minHeight: oversized ? 180 : 120, alignment: .topLeading)
            .albumPlate()
            .clipShape(RoundedRectangle(cornerRadius: AlbumRadius.card, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(AlbumPress())
        .accessibilityLabel("\(issue.title), \(issue.country)")
        .animation(Animation.easeOut(duration: 0.16).delay(AlbumMotion.delay(index: index, reduceMotion: reduceMotion)), value: store.searchPage.issues.count)
    }

    private func runSearch() {
        showShelf = false
        termsFocus = false
        store.updateSearch(terms: terms)
    }
}

/// Oversized catalog result. Quieter tiles stay in the grid beside it.
struct DiscoverWall: View {
    let issue: Issue
    var reduceMotion: Bool
    var pick: () -> Void

    var body: some View {
        Button(action: pick) {
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
                    .font(AlbumType.caption)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
            }
            .padding(AlbumSpace.m)
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
            .albumPlate()
            .contentShape(Rectangle())
        }
        .buttonStyle(AlbumPress())
        .accessibilityLabel("\(issue.title), \(issue.country)")
        .animation(Animation.easeOut(duration: 0.16).delay(AlbumMotion.delay(index: 0, reduceMotion: reduceMotion)), value: issue.id)
    }
}
