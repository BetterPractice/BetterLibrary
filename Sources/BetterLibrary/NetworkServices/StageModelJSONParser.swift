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

open class StageModelJSONParser<NextParserType: Parser>: TwoStageParser<ModelJSONParser, NextParserType> where NextParserType.InputType == Model {
    
    public var readingOptions: JSONSerialization.ReadingOptions {
        get {
            return firstStage.readingOptions
        }
        set {
            firstStage.readingOptions = newValue
        }
    }
    
    public var startPath: [Any]
    
    
    public init(nextParser: NextParserType, startPath: [Any] = []) {
        self.startPath = startPath
        super.init(firstStage: ModelJSONParser(), secondStage: nextParser)
    }

    open func prepareForSecondStage(_ input: Model) -> Model {
        return input.follow(path: startPath)
    }
}
