//
//  Event.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 4/13/17.
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

open class Event<ParamType> {
    
    private var registered: [(String, Invocation<ParamType, Void>)] = []
    
    open func add<TargetType: AnyObject>(target: TargetType, action: @escaping (TargetType) -> (ParamType) -> Void) -> DisposalObject {
        let invocation = Invocation(target: target, action: action)
        return add(invocation: invocation)
    }
    
    open func add(action: @escaping (ParamType) -> Void) -> DisposalObject {
        let invocation = Invocation(action: action)
        return add(invocation: invocation)
    }
    
    open func add(invocation: Invocation<ParamType, Void>) -> DisposalObject {
        let token = UUID().uuidString
        registered.append((token, invocation))
        
        let disposal = DisposalObject { [weak self] in
            self?.remove(by: token)
        }
        
        return disposal
    }
    
    private func remove(by token: String) {
        registered = registered.filter { $0.0 != token }
    }
    
    open func trigger(_ param: ParamType) {
        for (_, anInvocation) in registered {
            anInvocation.action(param)
        }
    }
}


