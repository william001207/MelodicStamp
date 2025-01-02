//
//  Observable.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/1.
//

import Foundation
import Combine

@dynamicMemberLookup
class Observable<M: AnyObject>: ObservableObject {
    var model: M
    
    init(_ model: M) {
        self.model = model
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<M, T>) -> T {
        get { model[keyPath: keyPath] }
        set {
            self.objectWillChange.send()
            model[keyPath: keyPath] = newValue
        }
    }
}
