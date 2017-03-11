//
//  ThreeStageParser.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 3/9/17.
//
//

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


