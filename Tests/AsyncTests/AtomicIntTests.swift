//
//  AtomicIntTests.swift
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

public class AtomicIntTests: XCTestCase {
    
    func testConcurrentIncrement() {
 
        let atomic: AtomicInt = 0
        let iterations = 100000
        
        DispatchQueue.concurrentPerform(iterations: iterations) { (i) in
            atomic += i
        }
        
        let targetSum = iterations * (iterations - 1) / 2
        XCTAssert(atomic.value == targetSum)
    }
    
    func testConcurrentIncrementPerformance() {
        // This is an example of a performance test case.
        self.measure {
            let atomic: AtomicInt = 0
            let iterations = 100000
            
            DispatchQueue.concurrentPerform(iterations: iterations) { (i) in
                atomic += i
            }
        }
    }
    
    public static var allTests : [(String, (AtomicIntTests) -> () throws -> Void)] {
        return [
            ("testConcurrentIncrement", testConcurrentIncrement),
            ("testConcurrentIncrementPerformance", testConcurrentIncrementPerformance),
        ]
    }    
}
