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

public class Event<ParamType> {
    
    public static func +=<ParamType>(lhs: Event<ParamType>, rhs: @escaping (ParamType) -> Void) {
        lhs.add(action: rhs)
    }
    
    public static func +=<ParamType>(lhs: Event<ParamType>, rhs: Invocation<ParamType>) {
        lhs.add(invocation: rhs)
    }
    
    private var registered: [(String, Invocation<ParamType>)] = []
    
    @discardableResult
    public func add<TargetType: AnyObject>(target: TargetType, action: @escaping (TargetType) -> (ParamType) -> Void) -> String {
        let invocation = Invocation(target: target, action: action)
        return add(invocation: invocation)
    }
    
    @discardableResult
    public func add(action: @escaping (ParamType) -> Void) -> String {
        let invocation = Invocation(action: action)
        return add(invocation: invocation)
    }
    
    @discardableResult
    public func add(invocation: Invocation<ParamType>) -> String {
        let token = UUID().uuidString
        registered.append((token, invocation))
        return token
    }
    
    public func remove(by token: String) {
        registered = registered.filter { $0.0 != token }
    }
    
    public func fire(_ param: ParamType) {
        for (_, anInvocation) in registered {
            anInvocation.action(param)
        }
    }
}


