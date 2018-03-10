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
    
    open var hasPendingTasks: Bool {
        return syncQueue.sync {
            return pendingTasks.count > 0
        }
    }
    
    private var _isReady = false
    public var isReady: Bool {
        return syncQueue.sync {
            return _isReady
        }
    }
    
    open func track(identifier: IdentifierType, task: AsyncTask<ItemType>) {
        syncQueue.sync {
            guard !_isReady else {
                fatalError("Cannot call \(#function) once TaskJoiner is marked as ready.")
            }
            _ = task.asyncWait(queue: syncQueue) { (result) -> Void in
                self.pendingTasks.remove(identifier)
                self.taskResults[identifier] = result
                
                self.finalizeIfReady()
            }
            pendingTasks.insert(identifier)
        }
    }
    
    open func markReady() {
        syncQueue.sync {
            guard !_isReady else {
                fatalError("\(#function) cannot be called multiple times.")
            }
            
            _isReady = true
            finalizeIfReady()
        }
    }
    
    private func finalizeIfReady() {
        if _isReady && pendingTasks.count == 0 {
            setSuccess(taskResults)
        }
    }
}
