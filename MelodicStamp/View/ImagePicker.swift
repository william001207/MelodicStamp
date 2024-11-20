//
//  ImagePicker.swift
//  MelodicStamp
//
//  Created by 屈志健 on 2024/11/20.
//

import SwiftUI
import AppKit

struct ImagePicker: NSViewControllerRepresentable {
    @Binding var image: NSImage?
    
    func makeNSViewController(context: Context) -> NSViewController {
        let viewController = NSViewController()
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.allowedFileTypes = ["jpg", "jpeg", "png", "bmp", "gif", "tiff"]
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.canCreateDirectories = false
            panel.title = "选择封面图片"
            
            if panel.runModal() == .OK, let url = panel.url, let nsImage = NSImage(contentsOf: url) {
                self.image = nsImage
            }
        }
        return viewController
    }
    
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
}
