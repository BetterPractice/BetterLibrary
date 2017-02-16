//
//  FloatConvertable.swift
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

public protocol FloatConvertable {
    var asFloat: Float { get }
}

extension Float: FloatConvertable {
    public var asFloat: Float {
        return self
    }
}

extension Double: FloatConvertable {
    public var asFloat: Float {
        return Float(self)
    }
}

extension Float80: FloatConvertable {
    public var asFloat: Float {
        return Float(self)
    }
}


extension Model {
    public var convertedFloat: Float? {
        if let value = value as? FloatConvertable {
            return value.asFloat
        }
        return nil
    }
    
    public func convertedFloatValue() throws -> Float {
        if let convertedInt = convertedInt {
            return Float(convertedInt)
        }
        
        let converted: FloatConvertable = try impliedUnwrap()
        return converted.asFloat
    }
   
}
