//
//  IOSAnalysisView.swift
//  SDK Analyzer
//
//  iOS app analysis flow with authentication
//

import SwiftUI

struct IOSAnalysisView: View {
    let onBack: () -> Void

    @StateObject private var progress = AnalysisProgress()
    @State private var email = ""
    @State private var password = ""
    @State private var twoFACode = ""
    @State private var appStoreURL = ""
    @State private var isAuthenticated = false
    @State private var authenticatedEmail: String?
    @State private var showingAuthSheet = false
    @State private var needs2FA = false
    @State private var reportPath: String?
    @State private var workDirectory: String?

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
                    case .authenticating:
                        progressView(message: "Authenticating with Apple ID...")
                    case .downloading:
                        progressView(message: "Downloading app from App Store...")
                    case .analyzing:
                        progressView(message: "Analyzing frameworks and SDKs...")
                    case .completed:
                        completedView
                    case .failed(let error):
                        errorView(error: error)
                    }
                }
                .padding()
            }
        }
        .onAppear(perform: checkAuthentication)
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

            Image(systemName: "apple.logo")
            Text("iOS Analysis")
                .font(.headline)

            Spacer()

            if let email = authenticatedEmail {
                Text("✓ \(email)")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var inputForm: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("App Store URL")
                .font(.headline)

            TextField("https://apps.apple.com/us/app/example/id1234567890", text: $appStoreURL)
                .textFieldStyle(.roundedBorder)

            Text("Enter the App Store link to the app you want to analyze")
                .font(.caption)
                .foregroundColor(.secondary)

            if !isAuthenticated {
                Text("⚠️ Not Authenticated")
                    .font(.caption)
                    .foregroundColor(.orange)

                Text("You'll be prompted to authenticate with your Apple ID")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: startAnalysis) {
                Text("Analyze App")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(appStoreURL.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .disabled(appStoreURL.isEmpty)
        }
        .padding()
        .sheet(isPresented: $showingAuthSheet) {
            authenticationSheet
        }
    }

    private var authenticationSheet: some View {
        VStack(spacing: 20) {
            Image(systemName: "key.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)

            Text(needs2FA ? "Two-Factor Authentication" : "Apple ID Authentication")
                .font(.title2)
                .fontWeight(.bold)

            if needs2FA {
                Text("A verification code has been sent to your devices")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                TextField("6-digit code", text: $twoFACode)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .multilineTextAlignment(.center)
                    .font(.title3)

                HStack {
                    Button("Cancel") {
                        showingAuthSheet = false
                        needs2FA = false
                        progress.updateState(.idle)
                    }
                    .buttonStyle(.plain)

                    Button("Verify") {
                        verify2FA()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(twoFACode.isEmpty)
                }
            } else {
                Text("To download iOS apps, authenticate with your Apple ID")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Cancel") {
                        showingAuthSheet = false
                        progress.updateState(.idle)
                    }
                    .buttonStyle(.plain)

                    Button("Authenticate") {
                        authenticate()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(email.isEmpty || password.isEmpty)
                }
            }
        }
        .padding(30)
        .frame(width: 400)
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

            Button("Analyze Another App") {
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

    private func checkAuthentication() {
        ShellScriptRunner.shared.checkIPAToolAuth { email in
            DispatchQueue.main.async {
                if let email = email {
                    self.isAuthenticated = true
                    self.authenticatedEmail = email
                }
            }
        }
    }

    private func startAnalysis() {
        if !isAuthenticated {
            showingAuthSheet = true
        } else {
            runAnalysis()
        }
    }

    private func authenticate() {
        progress.updateState(.authenticating)

        ShellScriptRunner.shared.authenticateIPATool(
            email: email,
            password: password,
            outputHandler: { output in
                progress.appendOutput(output)
            },
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let output):
                        if output.contains("enter 2FA code") || output.contains("failed to read auth code") {
                            needs2FA = true
                        } else {
                            isAuthenticated = true
                            authenticatedEmail = email
                            showingAuthSheet = false
                            runAnalysis()
                        }
                    case .failure(let error):
                        progress.updateState(.failed(error))
                        showingAuthSheet = false
                    }
                }
            }
        )
    }

    private func verify2FA() {
        ShellScriptRunner.shared.authenticateIPATool(
            email: email,
            password: password,
            authCode: twoFACode,
            outputHandler: { output in
                progress.appendOutput(output)
            },
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        isAuthenticated = true
                        authenticatedEmail = email
                        showingAuthSheet = false
                        needs2FA = false
                        runAnalysis()
                    case .failure(let error):
                        progress.updateState(.failed(error))
                        showingAuthSheet = false
                    }
                }
            }
        )
    }

    private func runAnalysis() {
        guard let scriptPath = ShellScriptRunner.shared.scriptPath(named: "detect-sdk-ios") else {
            progress.updateState(.failed(NSError(domain: "SDK Analyzer", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not find analysis script"])))
            return
        }

        progress.updateState(.downloading)

        ShellScriptRunner.shared.runScript(
            script: scriptPath,
            arguments: ["-u", appStoreURL],
            environment: ["SKIP_AUTH_CHECK": "true"],
            outputHandler: { output in
                progress.appendOutput(output)

                // Update state based on output
                if output.contains("Downloading") {
                    progress.updateState(.downloading)
                } else if output.contains("Analyzing") || output.contains("Extracting") {
                    progress.updateState(.analyzing)
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
        appStoreURL = ""
        reportPath = nil
        workDirectory = nil
    }
}
