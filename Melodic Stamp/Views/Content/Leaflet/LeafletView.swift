//
//  LeafletView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/13.
//

import SwiftUI

struct LeafletView: View {
    @Environment(PlayerModel.self) var player

    var body: some View {
        if let current = player.current {
            Color.blue
        } else {
            LeafletExcerpt()
        }
    }
}
