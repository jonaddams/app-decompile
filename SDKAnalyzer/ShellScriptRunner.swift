//
//  ShellScriptRunner.swift
//  SDK Analyzer
//
//  Handles execution of bundled shell scripts
//

import Foundation

class ShellScriptRunner {
    static let shared = ShellScriptRunner()

    private init() {}

    /// Get path to bundled script
    func scriptPath(named: String) -> String? {
        return Bundle.main.path(forResource: named, ofType: "sh")
    }

    /// Get path to bundled resource file
    func resourcePath(named: String, ofType type: String) -> String? {
        return Bundle.main.path(forResource: named, ofType: type)
    }

    /// Run shell script with real-time output
    func runScript(
        script: String,
        arguments: [String],
        environment: [String: String]? = nil,
        outputHandler: @escaping (String) -> Void,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            let outputPipe = Pipe()
            let errorPipe = Pipe()

            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = [script] + arguments

            // Set environment
            var env = ProcessInfo.processInfo.environment
            if let additionalEnv = environment {
                env.merge(additionalEnv) { (_, new) in new }
            }
            // Always add Homebrew to PATH
            if let currentPath = env["PATH"] {
                env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:\(currentPath)"
            } else {
                env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
            }
            process.environment = env

            process.standardOutput = outputPipe
            process.standardError = errorPipe

            var fullOutput = ""

            // Handle output in real-time
            outputPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                    fullOutput += output
                    outputHandler(output)
                }
            }

            errorPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                    fullOutput += output
                    outputHandler(output)
                }
            }

            do {
                try process.run()
                process.waitUntilExit()

                // Close handlers
                outputPipe.fileHandleForReading.readabilityHandler = nil
                errorPipe.fileHandleForReading.readabilityHandler = nil

                let exitCode = process.terminationStatus
                if exitCode == 0 {
                    completion(.success(fullOutput))
                } else {
                    completion(.failure(NSError(
                        domain: "ShellScriptRunner",
                        code: Int(exitCode),
                        userInfo: [NSLocalizedDescriptionKey: fullOutput]
                    )))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Run ipatool authentication
    func authenticateIPATool(
        email: String,
        password: String,
        authCode: String? = nil,
        outputHandler: @escaping (String) -> Void,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        var args = ["auth", "login", "--email", email, "--password", password, "--non-interactive"]
        if let code = authCode {
            args.append(contentsOf: ["--auth-code", code])
        }

        let process = Process()
        let outputPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["ipatool"] + args

        // Set PATH to include Homebrew
        var env = ProcessInfo.processInfo.environment
        if let currentPath = env["PATH"] {
            env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:\(currentPath)"
        } else {
            env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
        }
        process.environment = env

        process.standardOutput = outputPipe
        process.standardError = outputPipe

        var output = ""

        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if let text = String(data: data, encoding: .utf8), !text.isEmpty {
                output += text
                outputHandler(text)
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try process.run()
                process.waitUntilExit()

                outputPipe.fileHandleForReading.readabilityHandler = nil

                let exitCode = process.terminationStatus
                if exitCode == 0 || output.contains("success") {
                    completion(.success(output))
                } else {
                    completion(.failure(NSError(
                        domain: "Authentication",
                        code: Int(exitCode),
                        userInfo: [NSLocalizedDescriptionKey: output]
                    )))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Check if ipatool is authenticated
    func checkIPAToolAuth(completion: @escaping (String?) -> Void) {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["ipatool", "auth", "info"]

        // Set PATH
        var env = ProcessInfo.processInfo.environment
        if let currentPath = env["PATH"] {
            env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:\(currentPath)"
        } else {
            env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
        }
        process.environment = env

        process.standardOutput = pipe
        process.standardError = pipe

        DispatchQueue.global(qos: .utility).async {
            do {
                try process.run()
                process.waitUntilExit()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8), output.contains("email=") {
                    // Extract email
                    if let emailMatch = output.range(of: "email=[^ ]*") {
                        let emailPart = output[emailMatch]
                        let email = emailPart.components(separatedBy: "=").last?
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: "\u{001B}[0m", with: "") // Strip ANSI codes
                        completion(email)
                        return
                    }
                }
                completion(nil)
            } catch {
                completion(nil)
            }
        }
    }
}
