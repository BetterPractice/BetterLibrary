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
    
    private var registered: [(String, (ParamType) -> Void)] = []
    
    open func add(action: @escaping (ParamType) -> Void) -> DisposalToken {
        let identifier = UUID().uuidString
        registered.append((identifier, action))
        
        let token = BlockDisposalToken(
            action: Invocation.WeakAction(
                target: self,
                param: identifier,
                method: Event.remove))
        return token
    }
    
    private func remove(by token: String) {
        registered = registered.filter { $0.0 != token }
    }
    
    open func trigger(_ param: ParamType) {
        for (_, anAction) in registered {
            anAction(param)
        }
    }
}


