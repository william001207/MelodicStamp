//
//  FloatingPlayBarView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct FloatingPlayBarView: View {
    @EnvironmentObject private var model: FloatingWindowsModel
    @Namespace private var namespace
    
    @State var onHover: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                Player(namespace: namespace)
            }
            .clipShape(.rect(cornerRadius: 24))
        }
        .background(Color.clear)
        .frame(width: 800, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .frame(maxHeight: .infinity, alignment: .bottom)
        .frame(width: 800, alignment: .leading)
        .contentShape(RoundedRectangle(cornerRadius: 25))
    }
}
