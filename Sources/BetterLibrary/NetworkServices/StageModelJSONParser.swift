//
//  StageModelJSONParser.swift
//  BetterLibrary
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

public struct StageModelJSONParser<NextParserType: Parser>: Parser where NextParserType.InputType == Model {
    
    public var readingOptions: JSONSerialization.ReadingOptions = []
    public let nextParser: NextParserType
    
    public init(nextParser: NextParserType) {
        self.nextParser = nextParser
    }
    
    public func canParse(_ input: Data) -> Bool {
        return input.count > 0
    }
    
    public func parse(_ input: Data) throws -> NextParserType.OutputType {
        let json = try JSONSerialization.jsonObject(with: input, options: readingOptions)
        let model = Model(json)
        
        guard nextParser.canParse(model) else {
            throw ParserError.parserDeclined
        }
        
        let result = try nextParser.parse(model)
        return result
    }
}
