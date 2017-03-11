//
//  ResourcePool.swift
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

open class ResourcePool<ItemType: Hashable> {
    
    private var pool: Set<ItemType> = []
    private var available: Set<ItemType> = []
    
    private let syncQueue = DispatchQueue(label: "Resource Pool SyncQueue")
    private let condition = NSCondition()
    
    private let bounds: Range<Int>
    private let creationHandler: (Int) -> ItemType
    
    public var currentPoolSize: Int {
        return syncQueue.sync {
            return pool.count
        }
    }
    
    public var availableItemCount: Int {
        return syncQueue.sync {
            return available.count
        }
    }
    
    public init(bounds: Range<Int>, creationHandler: @escaping (Int) -> ItemType) {
        self.bounds = bounds
        self.creationHandler = creationHandler
    }
    
    open func acquireIfAvailable() -> ItemType? {
        return syncQueue.sync {
            if available.count > 0 {
                return available.removeFirst()
            } else if (pool.count - 1 < bounds.upperBound) {
                let created = creationHandler(pool.count)
                pool.insert(created)
                return created
            } else {
                return nil
            }
        }
    }
    
    open func acquire() -> ItemType {
        while true {
            if let item = acquireIfAvailable() {
                return item
            }
            condition.lock()
            condition.wait()
            condition.unlock()
        }
    }
    
    open func release(_ item: ItemType) {
        syncQueue.sync {
            assert(pool.contains(item), "Item was not created by this resource pool.")
            available.insert(item)
        }
        condition.lock()
        condition.signal()
        condition.unlock()
    }
    
    open func using<ResultType>(handler: (ItemType) throws -> ResultType) rethrows -> ResultType {
        let item = acquire()
        defer {
            release(item)
        }
        let result = try handler(item)
        return result
    }
}
