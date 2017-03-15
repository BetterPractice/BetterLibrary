//
//  StageHTTPURLResponseParser.swift
//  BetterLibrary NetworkServices
//
//  Created by Holly Schilling on 3/9/17.
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

public struct StageHTTPURLResponseParser<NextParserType: Parser>: Parser where NextParserType.InputType==Data {
    
    public var acceptableStatusCodes: [Int] = [
        200, // OK
        201, // Created
        202, // Accepted
        203, // Non-Authoritative Information
    ]
    
    public let nextParser: NextParserType
    
    public init(nextParser: NextParserType) {
        self.nextParser = nextParser
    }
    
    public func canParse(_ input: (Data, URLResponse)) -> Bool {
        guard let (data, response) = input as? (Data, HTTPURLResponse) else {
            return false
        }
        let statusCode = response.statusCode
        guard acceptableStatusCodes.contains(statusCode) else {
            return false
        }
        return nextParser.canParse(data)
    }
    
    public func parse(_ input: (Data, URLResponse)) throws -> NextParserType.OutputType {
        guard canParse(input) else {
            throw ParserError.parserDeclined
        }

        let (data, _) = input
        return try nextParser.parse(data)
    }
    
    
}
