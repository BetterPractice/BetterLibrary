//
//  AsyncTaskTests.swift
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
import Foundation
import Dispatch
@testable import Async

public class AsyncTaskTests: XCTestCase {
    
    func testDelayedCompletion() {
        let expectation = self.expectation(description: "Async wait not completed.")
        
        let minimumWait: TimeInterval = 2
        
        let start = Date()
        let task: AsyncTask<Void> = AsyncTask()
        task.asyncWait { (result) in
            defer {
                expectation.fulfill()
            }
            let elapsed = -start.timeIntervalSinceNow
            if elapsed < minimumWait {
                XCTFail("Async wait called too soon.")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + minimumWait) { 
            task.setResult(MethodResult())
        }
        
        waitForExpectations(timeout: minimumWait+1) { (error) in
            if let error = error {
                print("Async task test failed. Error: \(error)")
            }
        }
    }
    
    func testSyncWaitUncompleted() {
        let task: AsyncTask<Int> = AsyncTask()
        
        DispatchQueue.concurrentPerform(iterations: 1) {_ in
            sleep(1)
            task.setResult(1)
        }
        
        let result = task.wait()
        XCTAssert(result.isSuccessful, "Task is not successful")
    }
    
    func testSyncWaitCompleted() {
        let task: AsyncTask<Void> = AsyncTask()
        task.setResult(.success())
        
        let result = task.wait()
        XCTAssert(result.isSuccessful, "Task is not successful")
    }
    
    func testAsyncWaitUncomplete() {
        let expectation = self.expectation(description: "Async wait triggered.")
        
        let task: AsyncTask<Void> = AsyncTask()
        task.asyncWait { (result) in
            XCTAssert(result.isSuccessful, "Task is not successful")
            expectation.fulfill()
        }
        
        task.setResult(.success())
        
        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print("Async task failed to complete. Error: \(error)")
            }
        }
    }

    func testAsyncWaitCompleted() {
        
        let expectation = self.expectation(description: "Async wait triggered.")
        
        let task: AsyncTask<Void> = AsyncTask()
        
        task.setResult(.success())
        
        task.asyncWait { (result) in
            XCTAssert(result.isSuccessful, "Task is not successful")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print("Async task failed to complete. Error: \(error)")
            }
        }
    }

    public static var allTests : [(String, (AsyncTaskTests) -> () throws -> Void)] {
        return [
            ("testDelayedCompletion", testDelayedCompletion),
            ("testSyncWaitUncompleted", testSyncWaitUncompleted),
            ("testSyncWaitCompleted", testSyncWaitCompleted),
            ("testAsyncWaitUncomplete", testAsyncWaitUncomplete),
            ("testAsyncWaitCompleted", testAsyncWaitCompleted),
        ]
    }
}
