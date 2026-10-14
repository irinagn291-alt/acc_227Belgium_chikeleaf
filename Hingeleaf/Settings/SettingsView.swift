import PDFKit
import SwiftUI

/// Re-run onboarding, erase the album, contact, and the Colnect credit.
struct SettingsView: View {
    @ObservedObject var store: LeafStore
    var onRerun: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var confirmErase = false
    @State private var folioURL: URL?
    @AppStorage(AlbumHaptic.defaultsKey) private var haptics = true

    private let contact = URL(string: "https://hingeleaf-folio.pro/contact-us")
    private let credit = URL(string: "https://colnect.com")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AlbumBand(title: "SETTINGS")
                ScrollView {
                    VStack(alignment: .leading, spacing: AlbumSpace.l) {
                        VStack(alignment: .leading, spacing: AlbumSpace.s) {
                            Button("Run onboarding again") {
                                store.setOnboardingComplete(false)
                                onRerun()
                            }
                            .buttonStyle(AlbumQuiet())
                        }
                        .padding(AlbumSpace.m)
                        .albumPlate()

                        VStack(alignment: .leading, spacing: AlbumSpace.s) {
                            Toggle("Haptics", isOn: $haptics)
                                .font(AlbumType.body)
                                .foregroundStyle(DesignTokens.ink)
                                .tint(DesignTokens.accent)
                            if let folioURL {
                                ShareLink(item: folioURL) {
                                    Text("Share album folio")
                                        .font(AlbumType.headline)
                                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                }
                            } else {
                                Button("Export album folio") {
                                    folioURL = AlbumFolio.write(chart: store.chart)
                                }
                                .buttonStyle(AlbumQuiet())
                            }
                        }
                        .padding(AlbumSpace.m)
                        .albumPlate()

                        VStack(alignment: .leading, spacing: AlbumSpace.s) {
                            Text("Erase everything")
                                .font(AlbumType.headline)
                                .foregroundStyle(DesignTokens.ink)
                            Text("This deletes hinges, cancels, and grades on this device.")
                                .font(AlbumType.caption)
                                .foregroundStyle(DesignTokens.muted)
                                .fixedSize(horizontal: false, vertical: true)
                            Button("Erase everything") {
                                confirmErase = true
                            }
                            .buttonStyle(AlbumFill(kind: .destructive))
                        }
                        .padding(AlbumSpace.m)
                        .albumPlate()

                        VStack(alignment: .leading, spacing: AlbumSpace.s) {
                            if let contact {
                                Link(destination: contact) {
                                    Text("Contact Hingeleaf")
                                        .font(AlbumType.headline)
                                        .foregroundStyle(DesignTokens.ink)
                                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                        .contentShape(Rectangle())
                                }
                            }
                            if let credit {
                                Link(destination: credit) {
                                    Text("Catalog credit, Colnect")
                                        .font(AlbumType.headline)
                                        .foregroundStyle(DesignTokens.ink)
                                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                        .contentShape(Rectangle())
                                }
                            }
                        }
                        .padding(AlbumSpace.m)
                        .albumPlate()
                    }
                    .padding(AlbumSpace.l)
                }
            }
            .background(DesignTokens.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .frame(minHeight: 44)
                        .accessibilityLabel("Close settings")
                }
            }
            .alert("Erase everything?", isPresented: $confirmErase) {
                Button("Keep it", role: .cancel) {}
                Button("Erase everything", role: .destructive) {
                    Task {
                        await store.resetAllData()
                        dismiss()
                    }
                }
            } message: {
                Text("Hinges, cancels, and grades on this device are deleted.")
            }
        }
    }
}

enum AlbumFolio {
    static func write(chart: LeafChart) -> URL? {
        let page = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let data = renderer.pdfData { context in
            context.beginPage()
            let ink = UIColor.black
            ("Chikeleaf" as NSString).draw(at: CGPoint(x: 48, y: 48), withAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: ink
            ])
            var y: CGFloat = 100
            let seated = chart.mounts.compactMap { mount -> String? in
                guard let id = mount.issueID, let issue = chart.issues.first(where: { $0.id == id }) else { return nil }
                let grade = chart.plates.first { $0.issueID == id }?.grade
                let mark = grade.map { " grade \($0)" } ?? ""
                return "\(issue.catalogNumber)  \(issue.title)  \(issue.role.rawValue)\(mark)"
            }
            for line in seated {
                if y > 740 {
                    context.beginPage()
                    y = 48
                }
                (line as NSString).draw(in: CGRect(x: 48, y: y, width: 516, height: 24), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: ink
                ])
                y += 22
            }
            if seated.isEmpty {
                ("The leaf is blank." as NSString).draw(at: CGPoint(x: 48, y: y), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: ink
                ])
            }
        }
        guard let pdf = PDFDocument(data: data) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("hingeleaf-folio.pdf")
        return pdf.write(to: url) ? url : nil
    }
}
