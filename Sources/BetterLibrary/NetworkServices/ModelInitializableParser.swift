//
//  ModelInitializableParser.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 3/15/17.
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

public struct ModelInitializableParser<ResultType: ModelInitializable>: Parser {
    
    public func parse(_ input: Model) throws -> ResultType {
        let result = try ResultType.init(model:  input)
        return result
    }
}

public struct ModelInitializableArrayParser<ResultType: ModelInitializable>: Parser {
    
    public func canParse(_ input: Model) -> Bool {
        return input.isArray
    }
    
    public func parse(_ input: Model) throws -> [ResultType] {
        guard let inputArray = input.array else {
            throw ParserError.parserDeclined
        }
        
        var result = [ResultType]()
        
        for anItem in inputArray {
            let parsed = try ResultType.init(model: anItem)
            result.append(parsed)
        }
        
        return result
    }
    
}
