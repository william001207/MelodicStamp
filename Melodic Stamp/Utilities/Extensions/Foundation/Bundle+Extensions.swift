//
//  Bundle+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/10.
//

import Foundation

extension Bundle {
    var appName: String {
        getInfo("CFBundleName") ?? "⚠️"
    }

    var displayName: String {
        getInfo("CFBundleDisplayName") ?? "⚠️"
    }

    var bundleID: String {
        getInfo("CFBundleIdentifier") ?? "⚠️"
    }

    var copyright: String {
        getInfo("NSHumanReadableCopyright") ?? "⚠️"
    }

    var appBuild: Int? {
        Int(getInfoDictionary("CFBundleVersion") ?? "")
    }

    var appVersion: String? {
        getInfoDictionary("CFBundleShortVersionString")
    }

    func getInfo(_ key: String) -> String? {
        localizedInfoDictionary?[key] as? String
    }
    
    func getInfoDictionary(_ key: String) -> String? {
        infoDictionary?[key] as? String
    }
}
