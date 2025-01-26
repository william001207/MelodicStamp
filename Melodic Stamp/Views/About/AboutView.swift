//
//  AboutView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import Luminare
import SFSafeSymbols
import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) private var openURL

    @State private var isVersionCopied: Bool = false
    @State private var copyVersionDispatch: DispatchWorkItem?

    var body: some View {
        HStack(spacing: 25) {
            appIconView()
                .shadow(radius: 24)
                .motionCard(scale: 1.02)
                .padding(8)

            VStack(alignment: .leading, spacing: 17.5) {
                titleView()

                VStack(alignment: .leading, spacing: 4) {
                    AliveButton {
                        openURL(.organization)
                    } label: {
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(copyrightText)
                                .fontWidth(.expanded)
                                .bold()

                            Image(.logo)
                                .resizable()
                                .scaledToFill()
                                .padding(.vertical, 0.5)
                                .padding(.top, 3)
                                .padding(.bottom, -1)
                                .frame(height: .preferredPointSize(forTextStyle: .body))
                        }
                        .fixedSize()
                    }

                    AliveButton {
                        openURL(.repository)
                    } label: {
                        HStack {
                            Text("Open sourced on GitHub")
                        }
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    }

                    versionView()
                }
            }
        }
        .containerBackground(for: .window) {
            gradientView()
                .continuousRippleEffect()
        }
        .padding(.horizontal, 25)
        .padding(100)
        .ignoresSafeArea()
        .padding(.bottom, -28)
        .fixedSize()
        .navigationTitle(.init(verbatim: ""))
        .preferredColorScheme(.light)
    }

    private var appNameText: String {
        String(localized: .init("About: Application Name", defaultValue: "Melodic Stamp"))
    }

    private var previewText: String {
        String(localized: .init("About: Preview", defaultValue: "Preview"))
    }

    private var copyrightText: String {
        String(localized: .init("About: Copyright", defaultValue: "© 2024→Future"))
    }

    @ViewBuilder private func appIconView() -> some View {
        Image("AppIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 72)
    }

    @ViewBuilder private func titleView() -> some View {
        HStack {
            Text(appNameText)
                .fontWeight(.black)

            Text(previewText)
                .fontWeight(.thin)
                .foregroundStyle(.tertiary)
        }
        .font(.title)
        .fontWidth(.expanded)
    }

    @ViewBuilder private func versionView() -> some View {
        if let version = Bundle.main.appVersion {
            let build = Bundle.main.appBuild.flatMap(String.init) ?? ""
            let hasBuild = !build.isEmpty

            let combined: String = if hasBuild {
                String(localized: .init(
                    "About: Version Template",
                    defaultValue: "\(version) (\(build))"
                ))
            } else {
                version
            }

            AliveButton {
                NSPasteboard.general.setString(combined, forType: .string)

                copyVersionDispatch?.cancel()
                withAnimation {
                    isVersionCopied = true
                }

                let dispatch = DispatchWorkItem {
                    withAnimation {
                        isVersionCopied = false
                    }
                }
                copyVersionDispatch = dispatch
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: dispatch)
            } label: {
                Group {
                    if isVersionCopied {
                        Text("Copied to clipboard!")
                    } else {
                        HStack(spacing: 12) {
                            Text("Version")

                            Text(combined)
                                .monospaced()
                        }
                    }
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
        }
    }

    @ViewBuilder private func gradientView() -> some View {
        MeshGradient(
            width: 4,
            height: 4,
            points: [
                [0.0, 0.0], [0.33, 0.0], [0.86, 0.0], [1.0, 0.0],
                [0.0, 0.2], [0.33, 0.5], [0.66, 0.25], [1.0, 0.6],
                [0.0, 0.32], [0.33, 0.55], [0.66, 0.3], [1.0, 0.72],
                [0.0, 1.0], [0.33, 1.0], [0.66, 1.0], [1.0, 1.0]
            ],
            colors: [
                .init(hex: 0xB5A8FE), .init(hex: 0xD0B4FF), .init(hex: 0xF5CFFD), .init(hex: 0xFDCFCC),
                .init(hex: 0x9D8DFE), .init(hex: 0xC4BDFF), .init(hex: 0xFDDBFB), .init(hex: 0xFFEDD6),
                .init(hex: 0xBFBEFF), .init(hex: 0xD0D0FE), .init(hex: 0xCDEBFE), .init(hex: 0xCCFEEE),
                .init(hex: 0xC0D4FF), .init(hex: 0xD7F5FE), .init(hex: 0xE7FEF1), .init(hex: 0xE0FEE4)
            ]
        )
    }
}

#Preview {
    AboutView()
}
