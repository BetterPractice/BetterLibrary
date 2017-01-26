//
//  StringModel.swift
//  BetterLibrary Model
//
//  Created by Holly Schilling on 10/9/16.
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


public enum ModelError : Error {
    case NullObject
    case WrongType
    case MissingIndex(Int)
    case MissingKey(String)
}


public struct Model {
    
    public var value: Any?
    
    public var isNull: Bool {
        return value == nil
    }
    
    public init(_ rawValue : Any? = nil) {
        switch rawValue {
        case let rawArray as [Any]:
            value = Model.Translate(array: rawArray)
        case let rawObject as [String : Any]:
            value = Model.Translate(object: rawObject)
        case let model as Model:
            switch model.value {
            case let innerArray as [Any]:
                value = Model.Translate(array: innerArray)
            case let innerObject as [String : Any]:
                value = Model.Translate(object: innerObject)
            default:
                value = model.value
            }
            
        default:
            value = rawValue
        }
    }
    
    static func Translate(array :  [Any]) -> [Model] {
        var result = [Model]()
        for aValue in array {
            result.append(Model(aValue))
        }
        return result
    }
    
    static func Translate(object : [String : Any]) -> [String : Model] {
        var result = [String : Model]()
        for (aKey, aValue) in object {
            result[aKey] = Model(aValue)
        }
        return result
    }
}
