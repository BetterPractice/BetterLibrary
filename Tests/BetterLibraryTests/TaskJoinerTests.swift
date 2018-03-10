//
//  TaskJoinerTests.swift
//  BetterLibrary AsyncTests
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

import XCTest
import Dispatch
@testable import BetterLibrary

public class TaskJoinerTests: XCTestCase {
    
    let workQueue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 50
        return q
    }()
    
    func createStallTask<ResultType>(delay: useconds_t, result: ResultType) -> AsyncTask<ResultType> {
        return AsyncTask.createTask(workQueue: workQueue) { () -> ResultType in
            usleep(delay)
            return result
        }
    }
    
    
    func testSyncWait() {
        
        let joiner: TaskJoiner<Int, Int> = TaskJoiner()
        let iterations = 10000
        let multiplier = 9
        
        for i in 0..<iterations {
            let task = self.createStallTask(delay: 1000, result: i * multiplier)
            joiner.track(identifier: i, task: task)
        }
        joiner.markReady()
        
        do {
            let table = try joiner.wait()
            XCTAssert(table.count==iterations, "Wrong number of rows in result table.")
            
            for (aKey, aValue) in table {
                let aResult = try aValue.value()
                XCTAssert(aKey * multiplier == aResult, "Result mismatch.")
            }
        }
        catch {
            XCTFail("Task unexpectedly threw an error: \(error)")
        }
    }
    
    func testAsyncWait() {
        
        let joiner: TaskJoiner<Int, Int> = TaskJoiner()
        let iterations = 10000
        let multiplier = 9
        
        for i in 0..<iterations {
            let task = self.createStallTask(delay: 1000, result: i * multiplier)
            joiner.track(identifier: i, task: task)
        }
        
        joiner.markReady()
        
        let expectation = self.expectation(description: "Completion called once all tasks complete.")
        
        _ = joiner.asyncWait { (result) in
            do {
                let table = try result.value()
                XCTAssert(table.count==iterations, "Wrong number of rows in result table.")
                
                for (aKey, aValue) in table {
                    let aResult = try aValue.value()
                    XCTAssert(aKey * multiplier == aResult, "Result mismatch.")
                }
                expectation.fulfill()
            }
            catch {
                XCTFail("Task unexpectedly threw an error: \(error)")
            }
        }
        
        self.waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print("Unexpected error: \(error)")
            }
        }
    }
    
    public static var allTests : [(String, (TaskJoinerTests) -> () throws -> Void)] {
        return [
            ("testSyncWait", testSyncWait),
            ("testAsyncWait", testAsyncWait),
        ]
    }
}
