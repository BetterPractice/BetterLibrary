//
//  NetworkParserServiceTests.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 5/7/17.
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
import BetterLibrary

@discardableResult
func AssertThrows<T>(_ assertion: @autoclosure () throws -> T) -> Error {
    do {
        let value = try assertion()
        XCTFail("Assertion returned \(value) when it was expected to throw.")
    }
    catch {
        return error
    }
    fatalError()
}

class NetworkParserServiceTests: XCTestCase {
    
    struct PassthroughParser<T>: Parser {
        func parse(_ input: T) throws -> T {
            return input
        }
    }
    
    struct SimpleObject: ModelInitializable {
        
        var boolValue: Bool
        var intValue: Int
        var stringValue: String
        
        init(model: Model) throws {
            boolValue = try model["bool"].boolValue()
            intValue = try model["int"].intValue()
            stringValue = try model["string"].stringValue()
        }
    }
    
    let emptyURL: URL = URL(string: "http:///")!
    
    var emulator: StaticNetworkDataEmulator!
    var service: NetworkParseService!
    
    let simpleJSON: Data = {
        let dict: [String: Any] = [
            "bool": true,
            "int": 37,
            "string": "Hello World"
        ]
        let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
        return data
    }()
    
    override func setUp() {
        super.setUp()
        
        emulator = StaticNetworkDataEmulator()
        service = NetworkParseService(provider: emulator)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPassingData() {
        emulator.data = simpleJSON
        emulator.statusCode = 200
        
        let task = service.fetchAndParse(
            url: emptyURL,
            dataParser: PassthroughParser())
        
        let result = try! task.wait()
        XCTAssert(result==simpleJSON, "Data doesn't match expected value")
    }
    
    func testInvalidStatusCode() {
        emulator.data = simpleJSON
        emulator.statusCode = 400
        
        let task = service.fetchAndParse(
            url: emptyURL,
            dataParser: PassthroughParser())
        
        AssertThrows(try task.wait())
    }
    
    func testNoData() {
        emulator.data = nil
        emulator.statusCode = 200
        
        let task = service.fetchAndParse(
            url: emptyURL,
            dataParser: PassthroughParser())
        
        AssertThrows(try task.wait())
    }
    
    func testModelValues() {
        emulator.data = simpleJSON
        emulator.statusCode = 200
        
        let task = service.fetchAndParse(
            url: emptyURL,
            modelParser: PassthroughParser())
        
        do {
            let model = try task.wait()
            
            let intValue = try model["int"].intValue()
            XCTAssert(intValue == 37, "Unexpected integer value: \(intValue)")
            
            let boolValue = try model["bool"].boolValue()
            XCTAssert(boolValue == true, "Unexpected bool value: \(boolValue)")
            
            let stringValue = try model["string"].stringValue()
            XCTAssert(stringValue == "Hello World", "Unexpected string value: \(stringValue)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
    }
    
    func testSimpleParser() {
        emulator.data = simpleJSON
        emulator.statusCode = 200
        
        let parser = BlockParser { (model: Model) -> Int in
            return try model["int"].intValue()
        }
        let task = service.fetchAndParse(url: emptyURL, modelParser: parser)
        
        do {
            let intValue = try task.wait()
            XCTAssert(intValue==37, "Wrong value parsed.")
        }
        catch {
            XCTFail("Unexpected error: \(error)")
        }
        
    }
    
    func testModelInitializable() {
        emulator.data = simpleJSON
        emulator.statusCode = 200
        
        let task = service.fetchAndParse(
            url: emptyURL,
            modelParser: ModelInitializableParser<SimpleObject>())
        
        do {
            let obj = try task.wait()
            XCTAssert(obj.intValue == 37, "Unexpected integer value: \(obj.intValue)")
            XCTAssert(obj.boolValue == true, "Unexpected bool value: \(obj.boolValue)")
            XCTAssert(obj.stringValue == "Hello World", "Unexpected string value: \(obj.stringValue)")
        }
        catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    public static var allTests : [(String, (NetworkParserServiceTests) -> () throws -> Void)] {
        return [
            ("testPassingData", testPassingData),
            ("testInvalidStatusCode", testInvalidStatusCode),
            ("testNoData", testNoData),
            ("testModelValues", testModelValues),
            ("testSimpleParser", testSimpleParser),
            ("testModelInitializable", testModelInitializable),
        ]
    }
}
