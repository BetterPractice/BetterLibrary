//
//  TwoStageParser.swift
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

public struct TwoStageParser<FirstParserType: Parser, SecondParserType: Parser>: Parser where FirstParserType.OutputType==SecondParserType.InputType {
    
    public let firstStage: FirstParserType
    public let secondStage: SecondParserType
    
    public init(firstStage: FirstParserType, secondStage: SecondParserType) {
        self.firstStage = firstStage
        self.secondStage = secondStage
    }
    
    public func canParse(_ input: FirstParserType.InputType) -> Bool {
        return firstStage.canParse(input)
    }
    
    public func parse(_ input: FirstParserType.InputType) throws -> SecondParserType.OutputType {
        let firstResult = try firstStage.parse(input)
        
        guard secondStage.canParse(firstResult) else {
            throw ParserError.parserDeclined
        }
        
        let secondResult = try secondStage.parse(firstResult)
        return secondResult
    }
}
