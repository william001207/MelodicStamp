//
//  Bundle+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/10.
//

import Foundation

extension Bundle {
    var appName: String {
        self[localizedInfo: "CFBundleName"] ?? "⚠️"
    }

    var displayName: String {
        self[localizedInfo: "CFBundleDisplayName"] ?? "⚠️"
    }

    var bundleID: String {
        self[localizedInfo: "CFBundleIdentifier"] ?? "⚠️"
    }

    var copyright: String {
        self[localizedInfo: "NSHumanReadableCopyright"] ?? "⚠️"
    }

    var appBuild: Int? {
        self[info: "CFBundleVersion"].flatMap(Int.init)
    }

    var appVersion: String? {
        self[info: "CFBundleShortVersionString"]
    }

    subscript(localizedInfo key: String) -> String? {
        localizedInfoDictionary?[key] as? String
    }

    subscript(info key: String) -> String? {
        infoDictionary?[key] as? String
    }
}
