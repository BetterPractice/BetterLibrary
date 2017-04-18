//
//  Invocation.swift
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

public struct Invocation<ParamType, ReturnType> {
    
    public let action: (ParamType) -> ReturnType
    
    public init(action: @escaping (ParamType) -> ReturnType) {
        self.action = action
    }
    
    public init<TargetType: AnyObject>(target: TargetType, action: @escaping (TargetType) -> (ParamType) -> ReturnType) where ReturnType == Void {
        self.action = { [weak target] (param) in
            guard let target = target else {
                return
            }
            action(target)(param)
        }
    }
}
