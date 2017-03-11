//
//  IntegerConvertable.swift
//  BetterLibrary Model
//
//  Created by Holly Schilling on 2/16/17.
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

public protocol IntegerConvertable {
    var asInteger: Int { get }
}

extension Int: IntegerConvertable {
    public var asInteger: Int {
        return self
    }
}

extension Int8: IntegerConvertable {
    public var asInteger: Int {
        return Int(self)
    }
}
extension Int16: IntegerConvertable {
    public var asInteger: Int {
        return Int(self)
    }
}

extension Int32: IntegerConvertable {
    public var asInteger: Int {
        return Int(self)
    }
}

extension Int64: IntegerConvertable {
    public var asInteger: Int {
        return Int(self)
    }
}

extension UInt: IntegerConvertable {
    public var asInteger: Int {
        return Int(self)
    }
}

extension UInt8: IntegerConvertable {
    public var asInteger: Int {
        return Int(self)
    }
}
extension UInt16: IntegerConvertable {
    public var asInteger: Int {
        return Int(self)
    }
}

extension UInt32: IntegerConvertable {
    public var asInteger: Int {
        return Int(self)
    }
}

extension UInt64: IntegerConvertable {
    public var asInteger: Int {
        return Int(self)
    }
}

extension Model {
    
    public var convertedInt: Int? {
        if let value = value as? IntegerConvertable {
            return value.asInteger
        }
        return nil
    }
    
    public func convertedIntValue() throws -> Int {
        let converted: IntegerConvertable = try impliedUnwrap()
        return converted.asInteger
    }
}
