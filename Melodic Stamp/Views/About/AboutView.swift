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
    var body: some View {
        HStack {
            LuminareSection {
                ZStack {
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
                            .init(hex: 0x7DBEA3), .init(hex: 0x7DBEA3), .init(hex: 0xDBE79B), .init(hex: 0xDBE79B),
                            .init(hex: 0x7DBEA3), .init(hex: 0xEBF1E3), .init(hex: 0xDBE79B), .init(hex: 0xDBE79B),
                            .init(hex: 0x7DBEA3), .init(hex: 0xBDE4E0), .init(hex: 0xEBF1E3), .init(hex: 0xBDE4E0),
                            .init(hex: 0xBDE4E0), .init(hex: 0xBDE4E0), .init(hex: 0xBDE4E0), .init(hex: 0xBDE4E0)
                        ]
                    )

                    VStack {
                        Text("Melodic Stamp ")
                            .font(.system(.title, design: .serif, weight: .semibold)) +
                            Text("Preview")
                            .font(.system(.title, design: .serif, weight: .light).italic())
                    }
                    .frame(width: 300, height: 175)
                }
            }

            VStack(spacing: 10) {
                LuminareSection {
                    HStack(spacing: 10) {
                        Image("AppIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 45)
                            .padding(8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(Bundle.main.displayName)
                                .bold()

                            Text(Bundle.main.copyright)
                                .font(.system(.body, design: .default, weight: .regular))
                                .foregroundStyle(.secondary)

                            if let version = Bundle.main.appVersion {
                                let build = Bundle.main.appBuild.flatMap(String.init) ?? ""
                                let hasBuild = !build.isEmpty

                                let combined: String = if hasBuild {
                                    .init(localized: "\(version) (\(build))")
                                } else {
                                    version
                                }

                                AliveButton {
                                    NSPasteboard.general.setString(combined, forType: .string)
                                } label: {
                                    Text(combined)
                                        .font(.system(.subheadline, design: .monospaced, weight: .ultraLight))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .frame(width: 300, height: 77, alignment: .center)
                }

                HStack {
                    LuminareSection {
                        HStack {}
                            .frame(width: 145, height: 77, alignment: .center)
                    }

                    LuminareSection {
                        HStack {}
                            .frame(width: 145, height: 77, alignment: .center)
                    }
                }
            }
        }
        .padding(20)
        .padding(.top, 16)
        .background {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        }
        .edgesIgnoringSafeArea(.all)
        .padding(.bottom, -28)
        .fixedSize()
        .navigationTitle("")
    }
}

#Preview {
    AboutView()
}
