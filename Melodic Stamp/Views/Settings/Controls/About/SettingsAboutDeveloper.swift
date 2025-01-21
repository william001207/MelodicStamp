//
//  SettingsAboutDeveloper.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2025/1/21.
//

import SFSafeSymbols
import SwiftUI

struct SettingsAboutDeveloper: View {
    var body: some View {
        List {
            HStack {
                AsyncImage(url: URL(string: "https://avatars.githubusercontent.com/u/68179735?s=128&v=4")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 32, height: 32)

                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .clipShape(.rect(cornerRadius: 16))

                    case .failure:
                        EmptyView()

                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.vertical, 6)

                VStack(alignment: .leading) {
                    Group {
                        Text("KrLite")
                            .bold()
                        Text("Planning, design and development.")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }

            HStack {
                AsyncImage(url: URL(string: "https://avatars.githubusercontent.com/u/96913885?s=128&v=4")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 32, height: 32)

                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .clipShape(.rect(cornerRadius: 16))

                    case .failure:
                        EmptyView()

                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.vertical, 6)

                VStack(alignment: .leading) {
                    Group {
                        Text("Xinshao")
                            .bold()
                        Text("Design, testing and development support.")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    Form {
        SettingsAboutDeveloper()
    }
    .formStyle(.grouped)
}
