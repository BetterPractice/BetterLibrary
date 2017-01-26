//
//  BoolModel.swift
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
    public var bool : Bool? {
        return value as? Bool
    }
    
    public var isBool : Bool {
        return bool != nil
    }
    
    public func boolValue() throws -> Bool {
        if let bool = bool {
            return bool
        }
        throw ModelError.WrongType
    }
    
}
