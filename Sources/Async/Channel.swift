//
//  Channel.swift
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

open class Channel<ItemType> {
    
    private let syncQueue: DispatchQueue = DispatchQueue(label: "Channel Sync Queue")
    
    private let readCondition: NSCondition = NSCondition()
    private let writeCondition: NSCondition = NSCondition()
    
    
    public let maxCapacity: Int?
    private var itemQueue: [ItemType] = [ItemType]()
    

    public init(maxCapacity: Int? = nil) {
        self.maxCapacity = maxCapacity
    }
    
    public func write(item: ItemType) {
        func tryAppendItem() -> Bool {
            return syncQueue.sync {
                guard let maxCapacity = maxCapacity else {
                    itemQueue.append(item)
                    return true
                }
                if itemQueue.count < maxCapacity {
                    itemQueue.append(item)
                    return true
                } else {
                    return false
                }
            }
        }
        while true {
            if tryAppendItem() {
                readCondition.lock()
                readCondition.signal()
                readCondition.unlock()
                return
            }
            writeCondition.lock()
            writeCondition.wait()
            writeCondition.unlock()
        }
        
        
    }
    
    public func read() -> ItemType {
        func tryDequeueItem() -> ItemType? {
            return syncQueue.sync {
                guard itemQueue.count > 0 else {
                    return nil
                }
                return itemQueue.removeFirst()
            }
        }
        
        while true {
            if let item = tryDequeueItem() {
                writeCondition.lock()
                writeCondition.signal()
                writeCondition.unlock()
                return item
            }
            readCondition.lock()
            readCondition.wait()
            readCondition.unlock()
        }
    }   
    
}
