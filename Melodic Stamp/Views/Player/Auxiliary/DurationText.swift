//
//  DurationText.swift
//  Playground
//
//  Created by KrLite on 2024/11/17.
//

import SwiftUI

struct DurationText: View {
    var duration: Duration?
    var sign: FloatingPointSign = .plus
    var pattern: Duration.TimeFormatStyle.Pattern = .minuteSecond

    var body: some View {
        Text(formattedSign + (formattedDuration ?? "--:--"))
//            .contentTransition(.numericText())
            .animation(.bouncy, value: duration)
    }

    private var formattedSign: String {
        switch sign {
        case .plus:
            ""
        case .minus:
            "-"
        }
    }

    private var formattedDuration: String? {
        duration.map {
            $0.formatted(.time(pattern: pattern))
        }
    }
}

#Preview {
    VStack {
        DurationText(sign: .minus)
        DurationText(duration: .zero)
        DurationText(duration: .seconds(5))
        DurationText(duration: .seconds(128), sign: .minus)
        DurationText(duration: .seconds(3.14))
        DurationText(duration: .seconds(3 * 60 * 60))
    }
    .padding()
}
