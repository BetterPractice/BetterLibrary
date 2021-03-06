//
//  DisposalToken.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 4/17/17.
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

open class DisposalToken: Hashable, Comparable {
    
    public static func ==(lhs: DisposalToken, rhs: DisposalToken) -> Bool {
        return lhs === rhs
    }
    
    public static func <(lhs: DisposalToken, rhs: DisposalToken) -> Bool {
        let l = ObjectIdentifier(lhs)
        let r = ObjectIdentifier(rhs)
        return l < r
    }

    public private(set) var isDisposed: Bool = false
    
    deinit {
        dispose()
    }
    
    public func dispose() {
        guard !isDisposed else {
            return
        }
        disposalAction()
        
        isDisposed = true
    }
    
    open func disposalAction() {
        fatalError("Subclasses must implement \(#function).")
    }
    
    //MARK: - Hashable
    
    public var hashValue: Int {
        let identifier = ObjectIdentifier(self)
        return identifier.hashValue
    }
}

public final class BlockDisposalToken: DisposalToken {
    
    public let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public override func disposalAction() {
        action()
    }

}

