//
//  RoutePickerView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/2.
//

import AVKit
import SwiftUI

struct RoutePickerView: NSViewRepresentable {
    func makeNSView(context _: Context) -> AVRoutePickerView {
        let routePickerView = AVRoutePickerView()
        routePickerView.isRoutePickerButtonBordered = false

        return routePickerView
    }

    func updateNSView(_: AVRoutePickerView, context _: Context) {}
}

#Preview {
    RoutePickerView()
}
