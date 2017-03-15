//
//  TwoStageParser.swift
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

open class TwoStageParser<FirstParserType: Parser, SecondParserType: Parser>: Parser {
    
    public var firstStage: FirstParserType
    public var secondStage: SecondParserType
    
    public init(firstStage: FirstParserType, secondStage: SecondParserType) {
        self.firstStage = firstStage
        self.secondStage = secondStage
    }
    
    open func canParse(_ input: FirstParserType.InputType) -> Bool {
        return firstStage.canParse(input)
    }
    
    open func parse(_ input: FirstParserType.InputType) throws -> SecondParserType.OutputType {
        let firstResult = try firstStage.parse(input)

        let secondParserInput = try prepareForSecondStage(firstResult)
        
        guard secondStage.canParse(secondParserInput) else {
            throw ParserError.parserDeclined
        }
        
        let secondResult = try secondStage.parse(secondParserInput)
        return secondResult
    }
    
    open func prepareForSecondStage(_ firstParserResult: FirstParserType.OutputType) throws -> SecondParserType.InputType {
        guard let secondParserInput = firstParserResult as? SecondParserType.InputType else {
            fatalError("When parser types not aligned, \(#function) must be implemented.")
        }
        
        return secondParserInput
    }
}
