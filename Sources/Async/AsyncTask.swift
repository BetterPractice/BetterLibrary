//
//  AsyncTask.swift
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

open class AsyncTask<ResultType> {
    
    public class func createTask(dispatchQueue queue: DispatchQueue, block: @escaping () throws -> ResultType) -> AsyncTask<ResultType> {
        let task: AsyncTask<ResultType> = AsyncTask()
        queue.async {
            do {
                let result = try block()
                task.setResult(result)
            }
            catch {
                task.setResult(.error(error))
            }
        }
        return task
    }

    public class func createTask(operationQueue queue: OperationQueue, block: @escaping () throws -> ResultType) -> AsyncTask<ResultType> {
        let task: AsyncTask<ResultType> = AsyncTask()
        queue.addOperation {
            do {
                let result = try block()
                task.setResult(result)
            }
            catch {
                task.setResult(.error(error))
            }
        }
        return task
    }
    
    private let syncQueue = DispatchQueue(label: "AsyncTask Sync Queue")
    private let condition: NSCondition = NSCondition()
    private var _result: MethodResult<ResultType>?

    private var opCallback: (queue: OperationQueue, handler: (MethodResult<ResultType>)->Void)?
    private var dispatchCallback: (queue: DispatchQueue, handler: (MethodResult<ResultType>)->Void)?
    
    
    open var isCompleted: Bool {
        return syncQueue.sync {
            return _result != nil
        }
    }
    
    public init() {
        
    }
    
    open func setResult(_ result: MethodResult<ResultType>) {
        syncQueue.sync {
            performCallback(result)
        }
    }
    open func setResult(_ result: ResultType) {
        setResult(.success(result))
    }
    
    open func setError(_ error: Error) {
        setResult(.error(error))
    }
    
    open func wait() throws -> ResultType {
        func checkResult() -> MethodResult<ResultType>? {
            return syncQueue.sync {
                return _result
            }
        }
        
        while true {
            if let result = _result {
                return try result.value()
            }
            condition.lock()
            condition.wait()
            condition.unlock()
        }
    }
    
    open func asyncWait(queue: OperationQueue = .main, handler: @escaping (MethodResult<ResultType>) -> Void) {
        syncQueue.sync {
            opCallback = (queue, handler)
            
            if let result = _result {
                performCallback(result)
            }
        }
    }
    
    open func asyncWait(queue: DispatchQueue, handler: @escaping (MethodResult<ResultType>) -> Void) {
        syncQueue.sync {
            dispatchCallback = (queue, handler)
            
            if let result = _result {
                performCallback(result)
            }
        }
    }
    
    fileprivate func performCallback(_ result: MethodResult<ResultType>) {
        _result = result
        
        if let callback = opCallback {
            callback.queue.addOperation {
                callback.handler(result)
            }
        } else if let callback = dispatchCallback {
            callback.queue.async {
                callback.handler(result)
            }
        } else {
            condition.lock()
            condition.signal()
            condition.unlock()
        }
    }
}
