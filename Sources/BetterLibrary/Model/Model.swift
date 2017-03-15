//
//  Model.swift
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

import Foundation

public enum ModelError : Error {
    case nullObject
    case wrongType
    case notConvertable
    case missingIndex(Int)
    case missingKey(String)
    case invalidPathItem(Any)
}

internal extension Array where Element: Equatable {
    static func ==(lhs: [Element], rhs: [Element]) -> Bool {
        if lhs.count != rhs.count {
            return false
        }
        for i in 0..<lhs.count {
            if lhs[i] != rhs[i] {
                return false
            }
        }
        return true
    }
}

//func ==<K: Hashable, V: Equatable>(lhs: [K: V], rhs: [K: V]) -> Bool {
//    if lhs.count != rhs.count {
//        return false
//    }
//    for aKey in lhs.keys {
//        if lhs[aKey] != rhs[aKey] {
//            return false
//        }
//    }
//    return true
//}
//

public struct Model: Equatable {
    
    public static func ==(lhs: Model, rhs: Model) -> Bool {
        
        func innerCompare<T: Equatable>(type: T.Type, l: Any, r: Any) -> Bool {
            // Adapted from http://stackoverflow.com/questions/34778950/how-to-compare-any-value-types
            guard let l: T = l as? T, let r: T = r as? T else {
                fatalError("Cannot cast parameters to type \(type).")
            }
            return l==r
        }
        
        guard let lvalue = lhs.value else {
            return rhs.value == nil
        }
        
        guard let rvalue = rhs.value else {
            return false
        }

        let lType = type(of: lvalue)
        let rType = type(of: rvalue)
        
        guard lType == rType else {
            return false
        }

        switch (lType) {
        case is Bool.Type:
            return innerCompare(type: Bool.self, l: lvalue, r: rvalue)
        case is Int32.Type:
            return innerCompare(type: Int32.self, l: lvalue, r: rvalue)
        case is Int.Type:
            return innerCompare(type: Int.self, l: lvalue, r: rvalue)
        case is Int64.Type:
            return innerCompare(type: Int64.self, l: lvalue, r: rvalue)
        case is Float.Type:
            return innerCompare(type: Float.self, l: lvalue, r: rvalue)
        case is Double.Type:
            return innerCompare(type: Double.self, l: lvalue, r: rvalue)
        case is String.Type:
            return innerCompare(type: String.self, l: lvalue, r: rvalue)
        case is Data.Type:
            return innerCompare(type: Data.self, l: lvalue, r: rvalue)
        case is [Model].Type:
            let larray = lvalue as! [Model]
            let rarray = rvalue as! [Model]
            return larray == rarray
        case is [String: Model].Type:
            let ldict = lvalue as! [String: Model]
            let rdict = rvalue as! [String: Model]
            return ldict == rdict
        default:
            return false
        }
    }
    
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
    
    public func impliedUnwrap<ExpectedType>() throws -> ExpectedType {
        if let value = value as? ExpectedType {
            return value
        }  else if value == nil {
            throw ModelError.nullObject
        } else {
            throw ModelError.wrongType
        }
    }
    
    public func fullyUnwrapped() -> Any? {
        if let obj = object {
            var result: [String: Any] = [:]
            for (aKey, aValue) in obj {
                result[aKey] = aValue.fullyUnwrapped()
            }
            return result
        } else if let obj = array {
            var result: [Any] = []
            for aValue in obj {
                if let flattenedValue = aValue.fullyUnwrapped() {
                    result.append(flattenedValue)
                }
            }
            return result
        } else if let obj = value as? Model {
            return obj.fullyUnwrapped()
        } else if let obj = value {
            return obj
        }
        return nil
    }
    
    public func follow(path: [Any]) throws -> Model {
        var result = self
        for aStep in path {
            if let value = aStep as? String {
                result = try model(for: value)
            } else if let value = aStep as? Int {
                result = try model(at: value)
            } else {
                throw ModelError.invalidPathItem(aStep)
            }
        }
        return result
    }
    
    static func Translate(array:  [Any]) -> [Model] {
        return array.map { (item) -> Model in
            if let item = item as? Model {
                return item
            } else {
                return Model(item)
            }
        }
    }
    
    static func Translate(object: [String: Any]) -> [String: Model] {
        var result = [String : Model]()
        for (aKey, aValue) in object {
            if let aValue = aValue as? Model {
                result[aKey] = aValue
            } else {
                result[aKey] = Model(aValue)
            }
        }
        return result
    }
}
