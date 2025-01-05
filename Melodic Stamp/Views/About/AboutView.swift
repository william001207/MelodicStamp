//
//  AboutView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        HStack {
            Image("AppIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 45)
                .padding(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(Bundle.main.displayName)
                    .bold()
                
                Text(Bundle.main.copyright)
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
                    }
                }
            }
        }
        .padding(20)
        .padding(.top, 16)
        .background {
            VisualEffectView(material: .titlebar, blendingMode: .behindWindow)
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
