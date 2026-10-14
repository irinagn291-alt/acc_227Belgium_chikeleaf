import SwiftUI

/// Mount-locked root. The leaf stays up. Discover, wants, profile, crate, seen, and settings arrive as sheets.
struct ContentView: View {
    @StateObject private var store: LeafStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var activeMountID: UUID?
    @State private var sheet: LeafSheet?
    @State private var scanCover = false
    @State private var issue: Issue?
    @State private var loaded = false
    @State private var reviewKey: String?
    @State private var reviewApplied = false

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let directory = base.appendingPathComponent("Chikeleaf", isDirectory: true)
        _store = StateObject(wrappedValue: LeafStore(defaults: .standard, directory: directory))
    }

    var body: some View {
        Group {
            if !loaded {
                DesignTokens.bg
            } else if !store.chart.onboardingComplete {
                OnboardingView {
                    store.setOnboardingComplete(true)
                    applyReviewIfNeeded()
                }
            } else {
                LeafView(
                    store: store,
                    activeMountID: $activeMountID,
                    onDiscover: { sheet = .discover },
                    onWants: { sheet = .wants },
                    onProfile: { sheet = .profile },
                    onCrate: { sheet = .crate },
                    onSeen: { sheet = .seen },
                    onSettings: { sheet = .settings }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.bg.ignoresSafeArea())
        .task {
            if !loaded {
                await store.load()
                if activeMountID == nil {
                    activeMountID = store.chart.issues.first { $0.role == .hinged }?.mountID
                        ?? store.chart.mounts.first?.id
                }
                reviewKey = ReviewLaunch.screen
                loaded = true
                if store.chart.onboardingComplete {
                    applyReviewIfNeeded()
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            Task { await store.scenePhaseChanged(phase) }
        }
        .sheet(item: $sheet) { item in
            switch item {
            case .discover:
                DiscoverView(store: store, mountID: activeMountID, onScan: {
                    scanCover = true
                })
            case .wants:
                WantsView(store: store, onFind: {
                    sheet = .discover
                }, onSeat: { picked in
                    if let mount = picked.mountID {
                        activeMountID = mount
                    }
                    sheet = nil
                })
            case .profile:
                ProfileView(store: store)
            case .crate:
                CrateView(store: store) {
                    sheet = .discover
                }
            case .seen:
                SeenView(store: store)
            case .settings:
                SettingsView(store: store) {
                    sheet = nil
                }
            }
        }
        .sheet(item: $issue) { picked in
            NavigationStack {
                IssueView(store: store, issue: picked, mountID: activeMountID)
            }
        }
        .fullScreenCover(isPresented: $scanCover) {
            ScanView(store: store) { picked in
                scanCover = false
                sheet = nil
                issue = picked
            }
        }
    }

    private func applyReviewIfNeeded() {
        guard !reviewApplied else {
            return
        }
        reviewApplied = true
        switch reviewKey {
        case "log":
            sheet = .wants
        case "goals":
            sheet = .profile
        case "discover":
            sheet = .discover
        case "settings":
            sheet = .settings
        case "crate":
            sheet = .crate
        case "seen":
            sheet = .seen
        case "scan":
            scanCover = true
        default:
            break
        }
    }
}

enum LeafSheet: String, Identifiable {
    case discover
    case wants
    case profile
    case crate
    case seen
    case settings

    var id: String { rawValue }
}

#Preview {
    ContentView()
}
