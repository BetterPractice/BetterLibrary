//
//  TaskJoiner.swift
//  BetterLibrary Async
//
//  Created by Holly Schilling on 1/21/17.
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
import Dispatch

open class TaskJoiner<IdentifierType: Hashable, ItemType>: AsyncTask<[IdentifierType: MethodResult<ItemType>]> {
    
    private let syncQueue: DispatchQueue = DispatchQueue(label: "TaskJoiner SyncQueue")
    
    private var pendingTasks: Set<IdentifierType> = []
    public private(set) var taskResults: [IdentifierType: MethodResult<ItemType>] = [:]
    
    private var callbackQueue: OperationQueue?
    private var callback: (() -> Void)?
    
    private let condition: NSCondition = NSCondition()
    
    open var hasPendingTasks: Bool {
        return syncQueue.sync {
            return pendingTasks.count > 0
        }
    }
    
    open func markStart(identifier: IdentifierType) {
        syncQueue.sync {
            let _ = pendingTasks.insert(identifier)
        }
    }
    
    open func markCompletion(identifier: IdentifierType, result: MethodResult<ItemType>) {
        syncQueue.sync {
            pendingTasks.remove(identifier)
            taskResults[identifier] = result
            
            if pendingTasks.count == 0 {
                setResult(.success(taskResults))
            }
        }
    }
}
