import SwiftUI

/// Home mechanic. The perforated leaf never leaves. Hinge and Cancel fuse on the active mount.
struct LeafView: View {
    @ObservedObject var store: LeafStore
    @Binding var activeMountID: UUID?
    var onDiscover: () -> Void
    var onWants: () -> Void
    var onProfile: () -> Void
    var onCrate: () -> Void
    var onSeen: () -> Void
    var onSettings: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var noteFocus: Bool
    @State private var trayID: String?
    @State private var note = ""
    @State private var fault = ""
    @State private var working = false
    @State private var revealed = false
    @State private var success = false
    @State private var confirmPeel = false
    @State private var leafPage = 0

    private let pageSize = 12

    var body: some View {
        VStack(spacing: 0) {
            AlbumBand(title: "THE LEAF", decor: true)
                .opacity(revealed ? 1 : 0)
            if IssueFold.surface(store.chart) == .blank {
                AlbumEmpty(
                    title: "The leaf is blank. Find the first issue.",
                    line: "Search a country, a topic, or a catalog number.",
                    action: "Find a stamp",
                    go: onDiscover
                )
            } else {
                occupied
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DesignTokens.bg)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { noteFocus = false }
            }
        }
        .onAppear {
            if activeMountID == nil {
                activeMountID = preferredMount()
            }
            syncNote()
            revealed = true
        }
        .onChange(of: store.chart.plates) { _, _ in
            syncNote()
        }
        .alert("Peel the last mark?", isPresented: $confirmPeel) {
            Button("Keep it", role: .cancel) {}
            Button("Peel mark", role: .destructive) {
                commitPeel()
            }
        } message: {
            Text("The latest hinge or cancel comes off.")
        }
    }

    private var occupied: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: AlbumSpace.m) {
                    destinations
                    leafPager
                    LeafCanvasView(
                        mounts: visibleMounts,
                        issues: store.chart.issues,
                        grades: gradeMap,
                        cancelDays: cancelMap,
                        activeID: activeMountID,
                        onTap: selectMount
                    )
                    .frame(height: leafHeight(width: proxy.size.width))
                    .clipShape(RoundedRectangle(cornerRadius: AlbumRadius.card, style: .continuous))
                    .accessibilityElement(children: .contain)
                    tray
                }
                .padding(.horizontal, AlbumSpace.l)
                .padding(.top, AlbumSpace.m)
                .padding(.bottom, AlbumSpace.l)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .safeAreaInset(edge: .bottom) {
            verbs
                .padding(.horizontal, AlbumSpace.l)
                .padding(.top, AlbumSpace.m)
                .padding(.bottom, AlbumSpace.s)
                .background(DesignTokens.bg)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(DesignTokens.muted)
                        .frame(height: AlbumSpace.hairline)
                }
        }
    }

    private func leafHeight(width: CGFloat) -> CGFloat {
        let inner = max(width - AlbumSpace.l * 2, AlbumSpace.unit * 20)
        return PerforationBoard.preferredHeight(mountCount: visibleMounts.count, width: inner)
    }

    private var leafCount: Int {
        max(1, Int(ceil(Double(store.chart.mounts.count) / Double(pageSize))))
    }

    private var visibleMounts: [Mount] {
        let page = min(leafPage, leafCount - 1)
        let start = page * pageSize
        return Array(store.chart.mounts.dropFirst(start).prefix(pageSize))
    }

    private var gradeMap: [String: Int] {
        Dictionary(uniqueKeysWithValues: store.chart.plates.map { ($0.issueID, $0.grade) })
    }

    private var cancelMap: [String: Int] {
        Dictionary(store.chart.cancelMarks.map { ($0.issueID, $0.day) }, uniquingKeysWith: { _, latest in latest })
    }

    private var leafPager: some View {
        HStack(spacing: AlbumSpace.s) {
            Button("Previous leaf") { leafPage = max(0, leafPage - 1) }
                .buttonStyle(AlbumPress())
                .disabled(leafPage == 0)
            Text("Leaf \(AlbumCount.text(min(leafPage, leafCount - 1) + 1)) of \(AlbumCount.text(leafCount))")
                .font(AlbumType.caption)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(1)
                .layoutPriority(1)
            Button("Next leaf") { leafPage = min(leafCount - 1, leafPage + 1) }
                .buttonStyle(AlbumPress())
                .disabled(leafPage >= leafCount - 1)
            Button("Add a leaf") {
                store.appendLeaf()
                leafPage = max(0, (store.chart.mounts.count - 1) / pageSize)
            }
            .buttonStyle(AlbumPress())
        }
    }

    private var destinations: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AlbumSpace.s) {
                destination("Wants", "bookmark", "Wants, hinged stamps", onWants)
                destination("Profile", "person", "Country taste", onProfile)
                destination("Crate", "square.stack", "Owned copies", onCrate)
                destination("Seen", "calendar", "Cancel ledger", onSeen)
                destination("Settings", "gearshape", "Settings", onSettings)
            }
        }
        .opacity(revealed ? 1 : 0)
        .animation(fade(index: 1), value: revealed)
    }

    private func destination(_ title: String, _ symbol: String, _ label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AlbumSpace.xs) {
                Image(systemName: symbol)
                    .font(AlbumType.caption)
                    .accessibilityHidden(true)
                Text(title)
                    .font(AlbumType.caption)
                    .lineLimit(1)
            }
            .foregroundStyle(DesignTokens.ink)
            .padding(.horizontal, AlbumSpace.m)
            .frame(minHeight: 44)
            .albumPlate(radius: AlbumRadius.chip)
            .contentShape(Capsule())
        }
        .buttonStyle(AlbumPress())
        .accessibilityLabel(label)
    }

    private var tray: some View {
        VStack(alignment: .leading, spacing: AlbumSpace.s) {
            Text("In the tray")
                .font(AlbumType.caption)
                .foregroundStyle(DesignTokens.muted)
            let loose = IssueFold.looseTray(store.chart)
            if loose.isEmpty {
                Text("The tray is clear. Search fills it.")
                    .font(AlbumType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AlbumSpace.m)
                    .albumPlate(radius: AlbumRadius.chip)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AlbumSpace.s) {
                        ForEach(Array(loose.enumerated()), id: \.element.id) { index, issue in
                            Button {
                                trayID = issue.id
                                fault = ""
                            } label: {
                                VStack(alignment: .leading, spacing: AlbumSpace.xs) {
                                    Text(issue.title)
                                        .font(AlbumType.headline)
                                        .foregroundStyle(DesignTokens.ink)
                                        .lineLimit(2)
                                    Text(issue.catalogNumber)
                                        .font(AlbumType.catalog)
                                        .foregroundStyle(DesignTokens.muted)
                                        .lineLimit(1)
                                }
                                .padding(AlbumSpace.m)
                                .frame(minWidth: 160, minHeight: 44, alignment: .leading)
                                .albumPlate(radius: AlbumRadius.chip)
                                .overlay {
                                    if trayID == issue.id {
                                        RoundedRectangle(cornerRadius: AlbumRadius.chip, style: .continuous)
                                            .stroke(DesignTokens.accent, lineWidth: AlbumSpace.hairline)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(AlbumPress())
                            .accessibilityLabel("Loose \(issue.title)")
                            .accessibilityAddTraits(trayID == issue.id ? .isSelected : [])
                            .opacity(revealed ? 1 : 0)
                            .animation(fade(index: index + 2), value: revealed)
                        }
                    }
                }
            }
            if trayID != nil {
                Button("Cancel without a hinge") {
                    commitLooseCancel()
                }
                .buttonStyle(AlbumQuiet())
                .disabled(working)
                Button("Clear from tray") {
                    if let trayID {
                        store.discardLoose(issueID: trayID)
                        self.trayID = nil
                    }
                }
                .buttonStyle(AlbumQuiet())
            }
        }
    }

    private var verbs: some View {
        VStack(alignment: .leading, spacing: AlbumSpace.s) {
            Text(nextTap)
                .font(AlbumType.body)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
            if let seated = activeIssue {
                Text(roleLine(seated))
                    .font(AlbumType.caption)
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if success {
                HStack(spacing: AlbumSpace.s) {
                    Image("hlf_SuccessMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .accessibilityHidden(true)
                    Text("In hand.")
                        .font(AlbumType.headline)
                        .foregroundStyle(DesignTokens.accent)
                }
            }
            if showsGrade, let seated = activeIssue {
                gradeRow(seated)
                TextField("Local note", text: $note)
                    .font(AlbumType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .padding(AlbumSpace.s)
                    .albumPlate(radius: AlbumRadius.chip)
                    .focused($noteFocus)
                    .onSubmit(saveNote)
                    .onChange(of: noteFocus) { _, focused in
                        if !focused {
                            saveNote()
                        }
                    }
            }
            if !fault.isEmpty {
                Text(fault)
                    .font(AlbumType.caption)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if canHinge {
                Button(working ? "Seating" : "Hinge") {
                    commitHinge()
                }
                .buttonStyle(AlbumQuiet())
                .disabled(working)
            }
            Button(working ? "Cancelling" : "Cancel") {
                commitCancel()
            }
            .buttonStyle(AlbumFill(kind: .accent, loading: false))
            .disabled(!canCancel || working)
            .opacity(revealed ? 1 : 0)
            .animation(fade(index: 3), value: revealed)
            Button("Peel last mark") {
                confirmPeel = true
            }
            .buttonStyle(AlbumFill(kind: .destructive, expands: false))
            .disabled(working)
        }
    }

    private func gradeRow(_ issue: Issue) -> some View {
        HStack(spacing: AlbumSpace.s) {
            ForEach(1...5, id: \.self) { value in
                let selected = currentGrade(issue) == value
                Button {
                    commitGrade(issue, value)
                } label: {
                    Text(AlbumCount.text(value))
                        .font(AlbumType.headline)
                        .foregroundStyle(selected ? DesignTokens.bg : DesignTokens.ink)
                        .frame(minWidth: 44, minHeight: 44)
                        .background(Capsule().fill(selected ? DesignTokens.accent : DesignTokens.surface))
                        .overlay(Capsule().stroke(selected ? DesignTokens.accent : DesignTokens.muted, lineWidth: AlbumSpace.hairline))
                        .contentShape(Capsule())
                }
                .buttonStyle(AlbumPress())
                .accessibilityLabel("Grade \(AlbumCount.text(value))")
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
    }

    private var activeIssue: Issue? {
        guard let id = store.chart.mounts.first(where: { $0.id == activeMountID })?.issueID else {
            return nil
        }
        return store.chart.issues.first { $0.id == id }
    }

    private var canCancel: Bool {
        guard let issue = activeIssue else {
            return false
        }
        return IssueFold.cancelEnabled(issueID: issue.id, chart: store.chart)
    }

    private var canHinge: Bool {
        guard let trayID, let mount = activeMountID else {
            return false
        }
        let empty = store.chart.mounts.first { $0.id == mount }?.issueID == nil
        let loose = IssueFold.looseTray(store.chart).contains { $0.id == trayID }
        return empty && loose
    }

    private var showsGrade: Bool {
        activeIssue?.role == .cancelled
    }

    private var nextTap: String {
        guard let seated = activeIssue else {
            return "Pick a perforation, then hinge a stamp from the tray."
        }
        switch seated.role {
        case .hinged:
            return "\(seated.title) is hinged. Cancel it."
        case .cancelled:
            return "\(seated.title) is cancelled. Grade the copy."
        case .loose:
            return "\(seated.title) is still loose."
        }
    }

    private func roleLine(_ issue: Issue) -> String {
        switch issue.role {
        case .loose:
            return "Loose in the tray."
        case .hinged:
            return "Hinged. Cancel when the stamp is in hand."
        case .cancelled:
            return "Cancelled. Grade this copy from 1 to 5."
        }
    }

    private func fade(index: Int) -> Animation {
        .easeOut(duration: 0.2).delay(AlbumMotion.delay(index: index, reduceMotion: reduceMotion))
    }

    private func selectMount(_ id: UUID) {
        activeMountID = id
        fault = ""
        let mount = store.chart.mounts.first { $0.id == id }
        if mount?.issueID == nil {
            onDiscover()
        }
        syncNote()
    }

    private func preferredMount() -> UUID? {
        if let hinged = store.chart.issues.first(where: { $0.role == .hinged }) {
            return hinged.mountID
        }
        return store.chart.mounts.first?.id
    }

    private func currentGrade(_ issue: Issue) -> Int? {
        store.chart.plates.first { $0.issueID == issue.id }?.grade
    }

    private func syncNote() {
        if let issue = activeIssue, let plate = store.chart.plates.first(where: { $0.issueID == issue.id }) {
            note = plate.note
        } else {
            note = ""
        }
    }

    private func saveNote() {
        guard let issue = activeIssue, issue.role == .cancelled, let grade = currentGrade(issue) else {
            return
        }
        _ = store.grade(issueID: issue.id, grade: grade, note: note)
    }

    private func commitHinge() {
        guard let trayID, let mount = activeMountID else {
            return
        }
        working = true
        let result = store.hinge(issueID: trayID, mountID: mount)
        working = false
        switch result {
        case .success:
            AlbumHaptic.commit(.hinge)
            fault = ""
            self.trayID = nil
        case let .failure(error):
            fault = albumFault(error)
        }
    }

    private func commitCancel() {
        guard let issue = activeIssue else {
            return
        }
        working = true
        let result = store.cancel(issueID: issue.id)
        working = false
        switch result {
        case .success:
            AlbumHaptic.commit(.cancel)
            fault = ""
            flashSuccess()
        case let .failure(error):
            fault = albumFault(error)
        }
    }

    private func commitLooseCancel() {
        guard let trayID else {
            return
        }
        working = true
        let result = store.cancel(issueID: trayID)
        working = false
        switch result {
        case .success:
            AlbumHaptic.commit(.cancel)
            fault = ""
        case let .failure(error):
            fault = albumFault(error)
        }
    }

    private func commitPeel() {
        working = true
        let result = store.peel()
        working = false
        switch result {
        case .success:
            AlbumHaptic.commit(.peel)
            fault = ""
        case let .failure(error):
            fault = albumFault(error)
        }
    }

    private func commitGrade(_ issue: Issue, _ value: Int) {
        let result = store.grade(issueID: issue.id, grade: value, note: note)
        switch result {
        case .success:
            AlbumHaptic.commit()
            fault = ""
        case let .failure(error):
            fault = albumFault(error)
        }
    }

    private func flashSuccess() {
        success = true
        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            success = false
        }
    }
}
