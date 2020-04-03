//
//  Dynamic.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 23/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

class Dynamic<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?

    func bind(_ listener: Listener?) {
        self.listener = listener
    }

    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ val: T) {
        value = val
    }
}
