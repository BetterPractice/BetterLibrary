//
//  NotificationCenter+DisposalObject.swift
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

import Foundation

extension NotificationCenter {
    
    public func addObserver(forName name: NSNotification.Name?,
                            object: Any?,
                            queue: OperationQueue?,
                            method: @escaping (Notification) -> Void) -> DisposalToken {
        let obj = addObserver(forName: name,
                              object: object,
                              queue: queue,
                              using: method)
        return BlockDisposalToken(
            action: Invocation.WeakAction(
                target: self,
                param: obj,
                method: NotificationCenter.removeObserver))
    }
}
