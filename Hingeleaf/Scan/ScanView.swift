import AVFoundation
import SwiftUI

/// Full-screen pack scan. Digit runs of 8 to 14 become catalog lookups. Simulator uses chips and a field.
struct ScanView: View {
    @ObservedObject var store: LeafStore
    var onPicked: (Issue) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var capture = PackCapture()
    @FocusState private var codeFocus: Bool
    @State private var typed = ""
    @State private var notice = ""
    @State private var looking = false
    @State private var revealSpinner = false
    @State private var status = AVCaptureDevice.authorizationStatus(for: .video)

    private let samples = ["5012345678901", "012345678905", "4006381333931"]

    var body: some View {
        ZStack {
            DesignTokens.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                AlbumBand(title: "SCAN")
                ScrollView {
                    scanBody
                        .padding(AlbumSpace.l)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { codeFocus = false }
            }
        }
        .onChange(of: looking) { _, active in
            if active {
                revealSpinner = false
                Task {
                    try? await Task.sleep(nanoseconds: 150_000_000)
                    if looking {
                        revealSpinner = true
                    }
                }
            } else {
                revealSpinner = false
            }
        }
        .onAppear {
            status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .authorized {
                capture.start()
            }
        }
        .onDisappear {
            capture.stop()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background || phase == .inactive {
                capture.stop()
            } else if phase == .active && status == .authorized {
                capture.start()
            }
        }
        .onChange(of: capture.payload) { _, payload in
            guard let payload, !payload.isEmpty else {
                return
            }
            Task { await lookup(payload) }
        }
    }

    private var scanBody: some View {
        VStack(alignment: .leading, spacing: AlbumSpace.m) {
            if capture.hardware {
                PackPreview(session: capture.session)
                    .frame(maxWidth: .infinity)
                    .frame(height: AlbumSpace.unit * 40)
                    .clipShape(RoundedRectangle(cornerRadius: AlbumRadius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AlbumRadius.card, style: .continuous)
                            .stroke(DesignTokens.muted, lineWidth: AlbumSpace.hairline)
                    )
            } else {
                Text("No camera on this device. Use a sample code or type the pack number.")
                    .font(AlbumType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AlbumSpace.s) {
                        ForEach(samples, id: \.self) { code in
                            Button(code) {
                                Task { await lookup(code) }
                            }
                            .buttonStyle(AlbumPress())
                            .font(AlbumType.caption)
                            .foregroundStyle(DesignTokens.ink)
                            .padding(.horizontal, AlbumSpace.m)
                            .frame(minHeight: 44)
                            .albumPlate(radius: AlbumRadius.chip)
                            .disabled(looking)
                        }
                    }
                }
            }
            if status == .denied || status == .restricted {
                Text("The camera is off for Hingeleaf. Open Settings to change that, or type the pack code.")
                    .font(AlbumType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(AlbumFill())
            }
            if status == .notDetermined && capture.hardware {
                Text("The next step asks the system about the camera so a pack barcode can be read.")
                    .font(AlbumType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Continue") {
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        Task { @MainActor in
                            status = AVCaptureDevice.authorizationStatus(for: .video)
                            if granted {
                                capture.start()
                            }
                        }
                    }
                }
                .buttonStyle(AlbumFill())
            }
            TextField("Pack code or link", text: $typed)
                .font(AlbumType.body)
                .foregroundStyle(DesignTokens.ink)
                .padding(AlbumSpace.s)
                .albumPlate(radius: AlbumRadius.chip)
                .keyboardType(.numbersAndPunctuation)
                .focused($codeFocus)
                .submitLabel(.search)
                .onSubmit { Task { await lookup(typed) } }
            Button(looking ? "Looking" : "Look up") {
                codeFocus = false
                Task { await lookup(typed) }
            }
            .buttonStyle(AlbumFill(loading: revealSpinner))
            .disabled(looking || typed.trimmingCharacters(in: .whitespaces).isEmpty)
            if !notice.isEmpty {
                Text(notice)
                    .font(AlbumType.caption)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button("Close") { dismiss() }
                .buttonStyle(AlbumFill(kind: .destructive))
        }
    }

    private func lookup(_ payload: String) async {
        let trimmed = payload.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }
        if looking {
            return
        }
        looking = true
        await store.resolveScan(trimmed)
        looking = false
        if let issue = store.searchPage.issues.first, !store.searchPage.fromShelf || store.searchPage.notice == nil {
            onPicked(issue)
            return
        }
        if let issue = store.searchPage.issues.first {
            notice = store.searchPage.notice ?? "Showing the album shelf."
            onPicked(issue)
            return
        }
        notice = store.searchPage.notice ?? "No catalog code in that scan."
    }
}

struct PackPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PackPreviewHost {
        let host = PackPreviewHost()
        host.preview.session = session
        host.preview.videoGravity = .resizeAspectFill
        return host
    }

    func updateUIView(_ uiView: PackPreviewHost, context: Context) {
        uiView.preview.session = session
    }
}

final class PackPreviewHost: UIView {
    let preview = AVCaptureVideoPreviewLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(preview)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        preview.frame = bounds
    }
}

final class PackCapture: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate, @unchecked Sendable {
    let session = AVCaptureSession()
    @Published var payload: String?
    let hardware: Bool
    private let queue = DispatchQueue(label: "hlf.pack.capture")
    private var frames = 0
    private var lastFire = Date.distantPast
    private var inFlight = ""
    private var configured = false

    override init() {
        hardware = AVCaptureDevice.default(for: .video) != nil
        super.init()
    }

    func start() {
        guard hardware else {
            return
        }
        queue.async { [weak self] in
            self?.configureIfNeeded()
            if self?.session.isRunning == false {
                self?.session.startRunning()
            }
        }
    }

    func stop() {
        queue.async { [weak self] in
            if self?.session.isRunning == true {
                self?.session.stopRunning()
            }
        }
    }

    private func configureIfNeeded() {
        guard !configured, let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            return
        }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: queue)
        output.metadataObjectTypes = [.qr, .ean13, .ean8, .upce, .code128, .code39, .code93]
        let video = AVCaptureVideoDataOutput()
        video.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(video) {
            session.addOutput(video)
        }
        if device.isFocusModeSupported(.continuousAutoFocus) {
            try? device.lockForConfiguration()
            device.focusMode = .continuousAutoFocus
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()
        }
        session.commitConfiguration()
        configured = true
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        frames += 1
        if frames % 3 != 0 {
            return
        }
        guard let code = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = code.stringValue else {
            return
        }
        let now = Date()
        if now.timeIntervalSince(lastFire) < 1.7 {
            return
        }
        if value == inFlight, now.timeIntervalSince(lastFire) < 1.7 {
            return
        }
        inFlight = value
        lastFire = now
        let publish = value
        DispatchQueue.main.async { [weak self] in
            self?.payload = publish
        }
    }
}
