//
//  AttachedPictureCategoryView.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import SwiftUI

struct AttachedPictureCategoryView: View {
    var category: AttachedPictureCategory
    
    var body: some View {
        switch category {
        case .media:
            Text("Media")
        case .band:
            Text("Band")
        case .staff:
            Text("Staff")
        case .scenes:
            Text("Scenes")
        case .metadata:
            Text("Metadata")
        }
    }
}
