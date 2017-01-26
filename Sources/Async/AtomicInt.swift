//
//  AtomicInt.swift
//  BetterLibrary Async
//
//  Created by Holly Schilling on 1/21/17.
//
//  Copyright 2017 Better Practice Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import Dispatch

public final class AtomicInt: ExpressibleByIntegerLiteral {
    
    public static func +=(lhs: AtomicInt, rhs: Int) {
        lhs.increment(by: rhs)
    }
    
    private let syncQueue: DispatchQueue = DispatchQueue(label: "Atomic sync queue.")
    private var _value: Int
    
    public var value: Int {
        get {
            return syncQueue.sync {
                _value
            }
        }
        set {
            syncQueue.sync {
                _value = newValue
            }
        }
    }
    
    public init(integerLiteral value: Int) {
        _value = value
    }

    public init(_ value: Int) {
        self._value = value
    }
    
    public func increment(by x: Int) {
        syncQueue.sync {
            _value += x
        }
    }
}
