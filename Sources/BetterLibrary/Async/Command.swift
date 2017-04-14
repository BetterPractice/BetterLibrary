//
//  Command.swift
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

public struct Command<ParamType> {
    
    private let invocation: Invocation<ParamType>
    public let canPerformCommandChanged: Event<Bool> = Event()
    public var canPerformCommand: Bool = true {
        didSet {
            canPerformCommandChanged.fire(canPerformCommand)
        }
    }
    
    public init(invocation: Invocation<ParamType>) {
        self.invocation = invocation
    }
    
    public init<TargetType: AnyObject>(target: TargetType, action: @escaping (TargetType) -> (ParamType) -> Void) {
        invocation = Invocation(target: target, action: action)
    }
    
    public init(action: @escaping (ParamType) -> Void) {
        invocation = Invocation(action: action)
    }
    
    public func perform(arg: ParamType) {
        guard canPerformCommand else {
            return
        }
        invocation.action(arg)
    }
}
