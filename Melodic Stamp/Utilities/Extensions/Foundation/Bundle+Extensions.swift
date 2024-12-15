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
        Int(getInfo("CFBundleVersion") ?? "")
    }

    var appVersion: String? {
        getInfo("CFBundleShortVersionString")
    }

    func getInfo(_ key: String) -> String? {
        localizedInfoDictionary?[key] as? String
    }
}
