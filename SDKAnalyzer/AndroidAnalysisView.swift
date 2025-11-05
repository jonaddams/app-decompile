//
//  AndroidAnalysisView.swift
//  SDK Analyzer
//
//  Android app analysis flow via APK file selection
//

import SwiftUI

struct AndroidAnalysisView: View {
    let onBack: () -> Void

    @StateObject private var progress = AnalysisProgress()
    @State private var selectedAPKPath: String?
    @State private var reportPath: String?
    @State private var workDirectory: String?
    @State private var showingFilePicker = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()

            // Main content
            ScrollView {
                VStack(spacing: 20) {
                    switch progress.state {
                    case .idle:
                        inputForm
                    case .analyzing:
                        progressView(message: "Analyzing APK file...")
                    case .completed:
                        completedView
                    case .failed(let error):
                        errorView(error: error)
                    default:
                        EmptyView()
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Views

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .buttonStyle(.plain)

            Spacer()

            Image(systemName: "android.logo")
            Text("Android Analysis")
                .font(.headline)

            Spacer()

            // Placeholder for symmetry
            Text("")
                .frame(width: 80)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var inputForm: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("APK File")
                .font(.headline)

            if let path = selectedAPKPath {
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.green)

                    Text(URL(fileURLWithPath: path).lastPathComponent)
                        .font(.subheadline)
                        .lineLimit(1)

                    Spacer()

                    Button("Change") {
                        showingFilePicker = true
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            } else {
                Button(action: { showingFilePicker = true }) {
                    HStack {
                        Image(systemName: "folder")
                        Text("Select APK File")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            Text("Select the Android APK file you want to analyze")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Button(action: startAnalysis) {
                Text("Analyze APK")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedAPKPath == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .disabled(selectedAPKPath == nil)
        }
        .padding()
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.init(filenameExtension: "apk")!],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedAPKPath = url.path
                }
            case .failure(let error):
                progress.updateState(.failed(error))
            }
        }
    }

    private func progressView(message: String) -> some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text(message)
                .font(.headline)

            if !progress.currentStep.isEmpty {
                Text(progress.currentStep)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Show output log
            if !progress.output.isEmpty {
                GroupBox {
                    ScrollView {
                        Text(progress.output)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 200)
                }
                .padding(.top)
            }
        }
        .padding()
    }

    private var completedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Analysis Complete!")
                .font(.title)
                .fontWeight(.bold)

            if let path = reportPath {
                Button("Open Report") {
                    NSWorkspace.shared.open(URL(fileURLWithPath: path))
                }
                .buttonStyle(.borderedProminent)
            }

            if let workDir = workDirectory {
                Button("Clean Up Temporary Files") {
                    cleanupWorkDirectory(workDir)
                }
                .buttonStyle(.plain)
            }

            Button("Analyze Another APK") {
                resetState()
            }
            .buttonStyle(.plain)
        }
        .padding()
    }

    private func errorView(error: Error) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("Analysis Failed")
                .font(.title)
                .fontWeight(.bold)

            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                resetState()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Functions

    private func startAnalysis() {
        guard let apkPath = selectedAPKPath else { return }
        guard let scriptPath = ShellScriptRunner.shared.scriptPath(named: "detect-sdk-android") else {
            progress.updateState(.failed(NSError(domain: "SDK Analyzer", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not find analysis script"])))
            return
        }

        progress.updateState(.analyzing)

        ShellScriptRunner.shared.runScript(
            script: scriptPath,
            arguments: ["-f", apkPath],
            outputHandler: { output in
                progress.appendOutput(output)

                // Update progress based on output
                if output.contains("Extracting") {
                    progress.updateCurrentStep("Extracting APK contents...")
                } else if output.contains("Analyzing") {
                    progress.updateCurrentStep("Analyzing frameworks and libraries...")
                } else if output.contains("Generating") {
                    progress.updateCurrentStep("Generating report...")
                }
            },
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let output):
                        // Extract report path
                        if let range = output.range(of: "Full report: ") {
                            let reportLine = output[range.upperBound...].components(separatedBy: "\n").first ?? ""
                            let cleanPath = reportLine.replacingOccurrences(of: "\\x1b\\[[0-9;]*m", with: "", options: .regularExpression)
                            reportPath = cleanPath.trimmingCharacters(in: .whitespacesAndNewlines)
                        }

                        // Extract work directory
                        if let range = output.range(of: "Analysis Directory: ") {
                            let dirLine = output[range.upperBound...].components(separatedBy: "\n").first ?? ""
                            workDirectory = dirLine.trimmingCharacters(in: .whitespacesAndNewlines)
                        }

                        progress.updateState(.completed)
                    case .failure(let error):
                        progress.updateState(.failed(error))
                    }
                }
            }
        )
    }

    private func cleanupWorkDirectory(_ dir: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/rm")
        process.arguments = ["-rf", dir]
        try? process.run()
        process.waitUntilExit()
        workDirectory = nil
    }

    private func resetState() {
        progress.updateState(.idle)
        progress.output = ""
        selectedAPKPath = nil
        reportPath = nil
        workDirectory = nil
    }
}
