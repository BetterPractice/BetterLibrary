//
//  Event.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 4/13/17.
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

public class Event<TParam>
{
    private var invocations: Set<Invocation<TParam>> = []
    
    @discardableResult
    public func register(handler: @escaping (TParam) -> Void) -> Invocation<TParam>
    {
        let invocation = Invocation(handler)
        register(invocation: invocation)
        return invocation
    }
    
    public func register(invocation: Invocation<TParam>)
    {
        invocations.insert(invocation)
    }
    
    @discardableResult
    public func remove(invocation: Invocation<TParam>) -> Bool
    {
        return invocations.remove(invocation) != nil
    }
    
    public func invoke(param: TParam)
    {
        for anInvocation in invocations {
            anInvocation.invoke(param);
        }
    }
}


