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

public struct Invocation {
    
    // Prevent initialization
    fileprivate init() { }
    
    static func UnownedMethod<TargetType: AnyObject, ParamType, ReturnType>(
        target: TargetType,
        method: @escaping (TargetType) -> (ParamType) -> ReturnType)
        -> (ParamType) -> ReturnType {
            return { [unowned target] (param: ParamType) in
                return method(target)(param)
            }
    }
    
    static func WeakMethod<TargetType: AnyObject, ParamType>(
        target: TargetType,
        method: @escaping (TargetType) -> (ParamType) -> Void)
        -> (ParamType) -> Void {
            return { [weak target] (param: ParamType) in
                guard let target = target else {
                    return
                }
                return method(target)(param)
            }
    }
    
    
    
    static func WeakAction<TargetType: AnyObject, ParamType>(
        target: TargetType,
        param: ParamType,
        method: @escaping (TargetType) -> (ParamType) -> Void)
        -> () -> Void {
            return { [weak target] in
                guard let target = target else {
                    return
                }
                return method(target)(param)
            }
    }
    
}
