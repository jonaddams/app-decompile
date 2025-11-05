//
//  Models.swift
//  SDK Analyzer
//
//  Data models for the application
//

import Foundation

enum Platform {
    case iOS
    case android
}

enum AnalysisState {
    case idle
    case authenticating
    case downloading
    case analyzing
    case completed
    case failed(Error)
}

struct AnalysisResult {
    let reportPath: String
    let workDirectory: String?
}

class AnalysisProgress: ObservableObject {
    @Published var state: AnalysisState = .idle
    @Published var currentStep: String = ""
    @Published var output: String = ""

    func updateState(_ newState: AnalysisState) {
        DispatchQueue.main.async {
            self.state = newState
        }
    }

    func updateStep(_ step: String) {
        DispatchQueue.main.async {
            self.currentStep = step
        }
    }

    func appendOutput(_ text: String) {
        DispatchQueue.main.async {
            self.output += text + "\n"
        }
    }
}
