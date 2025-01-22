//
//  AboutViewPreview.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2025/1/22.
//

import SwiftUI

struct AboutViewPreview: View {
    var body: some View {
        let version = Bundle.main.appVersion
        let build = Bundle.main.appBuild.flatMap(String.init)
        let combined = "\(version ?? "000") \(build ?? "000")"

        VStack {
            ContinuousRippleEffectView {
                Text("Melodic Stamp ")
                    .fontDesign(.serif)
                    .font(.title)
                    .bold()

                    +

                    Text("Preview\n")
                    .foregroundStyle(Color.white.opacity(0.45))
                    .fontDesign(.serif)
                    .font(.title)
                    .italic()

                    +

                    Text("\nOpen Sourced On GitHub\n")
                    .fontDesign(.monospaced)
                    .font(.subheadline)

                    +

                    Text("\(combined)\n\n")
                    .foregroundStyle(Color.white.opacity(0.45))
                    .fontDesign(.monospaced)
                    .font(.subheadline)

                    +

                    Text("Cement")
                    .font(.custom("SFPro-ExpandedLight", size: 12))

                    +

                    Text(" Labs\n")
                    .font(.custom("SFPro-CompressedLight", size: 12))

                    +

                    Text("© 2024 → Future")
                    .foregroundStyle(Color.white.opacity(0.45))
                    .font(.custom("SFPro-CompressedLight", size: 12))
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .multilineTextAlignment(.leading)
        .preferredColorScheme(.dark)
        .frame(width: 350, height: 150)
    }
}

#Preview {
    AboutViewPreview()
}
