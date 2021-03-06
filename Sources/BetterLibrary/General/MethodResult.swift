//
//  MethodResult.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 1/21/17.
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

public enum MethodResult<T> {
    case success(T)
    case error(Error)
    
    public static func from(_ block: () throws -> T) -> MethodResult<T> {
        do {
            let result = try block()
            return .success(result)
        }
        catch {
            return .error(error)
        }
    }
    
    public init(_ value: T) {
        self = .success(value)
    }
    
    public init(error: Error) {
        self = .error(error)
    }
    
    public func value() throws -> T {
        switch self {
        case .success(let value):
            return value
        case .error(let e):
            throw e
        }
    }
    
    public var result: T? {
        if case .success(let value) = self {
            return value
        } else {
            return nil
        }
    }
    
    public var error: Error? {
        if case .error(let e) = self {
            return e
        } else {
            return nil
        }
    }
    
    public var isSuccessful: Bool {
        if case .success(_) = self {
            return true
        } else {
            return false
        }
    }
    
    public var isError: Bool {
        if case .error(_) = self {
            return true
        } else {
            return false
        }
    }
}
