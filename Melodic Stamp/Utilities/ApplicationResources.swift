//
//  ApplicationResources.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/21.
//

import Foundation

extension URL {
    static let github = URL(string: "https://github.com")!
    static let organization = github.appending(component: "Cement-Labs")
    static let repository = organization.appending(component: "Melodic-Stamp")
}
