//
//  DisposalObject.swift
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

public final class DisposalObject {
    
    public private(set) var isDisposed: Bool = false
    
    public let invocation: Invocation<Void, Void>
    
    public init(invocation: Invocation<Void, Void>) {
        self.invocation = invocation
    }
    
    public init(action: @escaping () -> Void) {
        self.invocation = Invocation(action: action)
    }
    
    public init<TargetType: AnyObject>(target: TargetType, action: @escaping (TargetType) -> (Void) -> Void) {
        self.invocation = Invocation(target: target, action: action)
    }
    
    deinit {
        dispose()
    }
    
    public func dispose() {
        guard !isDisposed else {
            return
        }
        
        invocation.action()
    }
}
