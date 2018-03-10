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
    
    public class func createTask(workQueue: Queue, work: @escaping () throws -> ResultType) -> AsyncTask<ResultType> {
        let asyncTask: AsyncTask<ResultType> = AsyncTask()
        workQueue.enqueue {
            let result = MethodResult.from(work)
            asyncTask.setMethodResult(result)
        }
        return asyncTask
    }
    
    private let syncQueue = DispatchQueue(label: "AsyncTask Sync Queue")
    private var condition: NSCondition?
    private var _result: MethodResult<ResultType>?

    private var _callback: (Queue, Callback<ResultType>)? = nil

    open var isCompleted: Bool {
        return syncQueue.sync {
            return _result != nil
        }
    }
    
    public init() {
        
    }
    
    open func setMethodResult(_ result: MethodResult<ResultType>) {
        syncQueue.sync {
            _result = result
            
            performCallbackIfReady()
        }
    }
    open func setSuccess(_ result: ResultType) {
        setMethodResult(.success(result))
    }
    
    open func setError(_ error: Error) {
        setMethodResult(.error(error))
    }
    
    open func wait() throws -> ResultType {
        func checkResult() -> MethodResult<ResultType>? {
            return syncQueue.sync {
                return _result
            }
        }

        // Create a condition variable to indicate that someone is waiting
        syncQueue.sync {
            condition = condition ?? NSCondition()
        }
        defer {
            syncQueue.sync {
                self.condition = nil
            }
        }
        
        // Create a local reference to ensure self.condition reference isn't used
        guard let condition = condition else {
            fatalError("Condition not set!")
        }
        
        while true {
            if let result = checkResult() {
                return try result.value()
            }
            condition.lock()
            condition.wait()
            condition.unlock()
        }
    }
    
    private func performCallbackIfReady() {
        //Should be called from withing the syncQueue only
        guard let result = _result else {
            return
        }
        
        if let (queue, block) = _callback {
            queue.enqueue {
                block.perform(result: result)
            }
        }
        
        if let condition = condition {
            condition.lock()
            condition.broadcast()
            condition.unlock()
        }
    }
    
    open func asyncWait<ContinuedResult>(queue: Queue = OperationQueue.main, handler: @escaping (MethodResult<ResultType>) throws -> ContinuedResult) -> AsyncTask<ContinuedResult> {
        let newTask = AsyncTask<ContinuedResult>()
        
        func runContinuation(_ result: MethodResult<ResultType>) {
            newTask.setMethodResult(.from({ try handler(result) }))
        }
        
        syncQueue.sync {
            _callback = (queue, .unified(runContinuation))
            
            performCallbackIfReady()
        }
        return newTask
    }
    
    open func continueTask<ContinuedResult>(queue: Queue = OperationQueue.main, successHandler: @escaping (ResultType) throws -> ContinuedResult) -> AsyncTask<ContinuedResult> {
        let newTask = AsyncTask<ContinuedResult>()
        
        func runSuccess(_ result: ResultType) {
            newTask.setMethodResult(.from({ try successHandler(result) }))
        }
        func forwardError(_ error: Error) {
            newTask.setError(error)
        }

        syncQueue.sync {
            _callback = (queue, Callback(success: runSuccess, error: forwardError))
            
            performCallbackIfReady()
        }
        return newTask
    }
}
