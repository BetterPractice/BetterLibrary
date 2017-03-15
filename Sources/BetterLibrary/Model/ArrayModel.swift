//
//  ArrayModel.swift
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


extension Model {
    
    public var array: [Model]? {
        return value as? [Model]
    }
    
    public var isArray: Bool {
        return array != nil
    }
    
    public func arrayValue() throws -> [Model] {
        return try impliedUnwrap()
    }
    
    public func model(at index: Int) throws -> Model {
        let array = try arrayValue()
        if index >= 0 && index < array.count {
            return array[index]
        }
        throw ModelError.missingIndex(index)
    }
    
    public subscript(index: Int) -> Model {
        get {
            if let array = array, index >= 0 && index < array.count {
                return array[index]
            }
            return Model()
        }
        set {
            if var array = array {
                array[index] = newValue
                value = array
            }
        }
    }
}
