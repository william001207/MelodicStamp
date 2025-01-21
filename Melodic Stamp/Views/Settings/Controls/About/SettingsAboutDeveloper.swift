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
                Image("KrLite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(.rect(cornerRadius: 16))
                    .padding(.vertical, 6)

                VStack(alignment: .leading) {
                    Group {
                        Text("KrLite")
                            .bold()
                        Text("Design and development.")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }

            HStack {
                Image("Xinshao")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(.rect(cornerRadius: 16))
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
