//
//  AdditionalMetadata.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/5.
//

import SwiftUI

struct NonHashableWrapper: Hashable {
    let description: String

    init(_ value: Any) {
        self.description = String(describing: value)
    }
}

typealias AdditionalMetadata = [AnyHashable: AnyHashable]

extension AdditionalMetadata {
    init(_ dictionary: [AnyHashable: Any]) {
        self = dictionary.reduce(into: [AnyHashable: AnyHashable]()) { result, pair in
            let (key, value) = pair
            if let hashableValue = value as? AnyHashable {
                result[key] = hashableValue
            } else {
                result[key] = NonHashableWrapper(value)
            }
        }
    }

//    var asAny: [AnyHashable: Any] {
//        self.reduce(into: [AnyHashable: Any]()) { result, pair in
//            let (key, value) = pair
//            if let wrapper = value as? NonHashableWrapper {
//                result[key] = wrapper.description // TODO: replace this with recovery logic if needed
//            } else {
//                result[key] = value
//            }
//        }
//    }
}
