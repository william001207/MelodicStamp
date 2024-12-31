//
//  SidebarTab.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SFSafeSymbols
import SwiftUI

protocol SidebarTab: Hashable, Identifiable, Equatable {
    var title: String { get }
    var systemSymbol: SFSymbol { get }
}
