//
//  ObjectModel.swift
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
    
    public var object: [String : Model]? {
        return value as? [String : Model]
    }
    
    public var isObject: Bool {
        return object != nil
    }
    
    public func objectValue() throws -> [String : Model] {
        if let object = object {
            return object
        }
        throw ModelError.WrongType
    }
    
    public func model(for key: String) throws -> Model {
        let value = try objectValue()
        if let result = value[key] {
            return result
        }
        throw ModelError.MissingKey(key)
    }
    
    public subscript(key: String) -> Model {
        get {
            if let result = object?[key] {
                return result
            }
            return Model()
        }
        set {
            if var object = object {
                object[key] = newValue
                value = object
            }
        }
    }
}
