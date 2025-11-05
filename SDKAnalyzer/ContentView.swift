//
//  ContentView.swift
//  SDK Analyzer
//
//  Main view with platform selection
//

import SwiftUI

struct ContentView: View {
    @State private var selectedPlatform: Platform?

    var body: some View {
        VStack(spacing: 20) {
            if selectedPlatform == nil {
                platformSelection
            } else if selectedPlatform == .iOS {
                IOSAnalysisView(onBack: { selectedPlatform = nil })
            } else if selectedPlatform == .android {
                AndroidAnalysisView(onBack: { selectedPlatform = nil })
            }
        }
        .frame(width: 600, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var platformSelection: some View {
        VStack(spacing: 30) {
            Image(systemName: "app.badge.checkmark")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("SDK Analyzer")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Analyze mobile apps to detect SDKs and frameworks")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 15) {
                Button(action: { selectedPlatform = .iOS }) {
                    HStack {
                        Image(systemName: "apple.logo")
                        Text("iOS (App Store)")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                Button(action: { selectedPlatform = .android }) {
                    HStack {
                        Image(systemName: "androidlogo")
                        Text("Android (APK)")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}
