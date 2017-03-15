//
//  ThreeStageParser.swift
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

public struct ThreeStageParser<FirstParserType: Parser, SecondParserType: Parser, ThirdParserType: Parser> : Parser where FirstParserType.OutputType == SecondParserType.InputType, SecondParserType.OutputType == ThirdParserType.InputType {
    
    public let firstParser: FirstParserType
    public let secondParser: SecondParserType
    public let thirdParser: ThirdParserType
    
    public func canParse(_ input: FirstParserType.InputType) -> Bool {
        return firstParser.canParse(input)
    }
    
    public func parse(_ input: FirstParserType.InputType) throws -> ThirdParserType.OutputType {
        let firstResult: FirstParserType.OutputType = try firstParser.parse(input)
        
        guard secondParser.canParse(firstResult) else {
            throw ParserError.parserDeclined
        }
        
        let secondResult: SecondParserType.OutputType = try secondParser.parse(firstResult)
        
        guard thirdParser.canParse(secondResult) else {
            throw ParserError.parserDeclined
        }
        
        let thirdResult: ThirdParserType.OutputType = try thirdParser.parse(secondResult)
        return thirdResult
    }
}


