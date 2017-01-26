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
@testable import Async

public class TaskJoinerTests: XCTestCase {
    
    func testSyncWait() {
        
        self.measure {
            let joiner: TaskJoiner<Int, Int> = TaskJoiner()
            let iterations = 100000
            
            for i in 0..<iterations {
                joiner.markStart(identifier: i)
            }
            
            DispatchQueue.concurrentPerform(iterations: iterations) { (i) in
                joiner.markCompletion(identifier: i, result: MethodResult(i))
            }
            do {
                let table = try joiner.wait().value()
                XCTAssert(table.count==iterations, "Wrong number of rows in result table.")
            }
            catch {
                XCTFail("Task unexpectedly threw an error: \(error)")
            }
        }
    }
    
    func testAsyncWait() {
        
        self.measure {
            let joiner: TaskJoiner<Int, Int> = TaskJoiner()
            let iterations = 100000
            
            for i in 0..<iterations {
                joiner.markStart(identifier: i)
            }
            
            DispatchQueue.concurrentPerform(iterations: iterations) { (i) in
                joiner.markCompletion(identifier: i, result: MethodResult(i))
            }
            
            let expectation = self.expectation(description: "Completion called once all tasks complete.")
            
            joiner.asyncWait { (result) in
                do {
                    let table = try result.value()
                    XCTAssert(table.count==iterations, "Wrong number of rows in result table.")
                    expectation.fulfill()
                }
                catch {
                    XCTFail("Task unexpectedly threw an error: \(error)")
                }
            }
            
            self.waitForExpectations(timeout: 2.0) { (error) in
                if let error = error {
                    print("Unexpected error: \(error)")
                }
            }
            
            do {
                let table = try joiner.wait().value()
                XCTAssert(table.count==iterations, "Wrong number of rows in result table.")
            }
            catch {
                XCTFail("Task unexpectedly threw an error: \(error)")
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
