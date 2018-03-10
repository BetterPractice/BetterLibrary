//
//  Callback.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 5/3/17.
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


fileprivate func filteredErrorOnly<T>(_ unifiedHandler: @escaping (MethodResult<T>) -> Void) -> (Error) -> Void {
    return { (error) in
        unifiedHandler(MethodResult(error: error))
    }
}

fileprivate func filteredSuccessOnly<T>(_ unifiedHandler: @escaping (MethodResult<T>) -> Void) -> (T) -> Void {
    return { (value) in
        unifiedHandler(MethodResult(value))
    }
}

public enum Callback<ParamType> {
    case none
    case errorOnly((Error) -> Void)
    case successOnly((ParamType) -> Void)
    case unified((MethodResult<ParamType>) -> Void)
    case split((ParamType) -> Void, (Error) -> Void)
    
    
    public init(success: ((ParamType) -> Void)? = nil, error: ((Error) -> Void)? = nil) {
        if
            let success = success,
            let error = error {
                self = .split(success, error)
        } else if
            let success = success {
                self = .successOnly(success)
        } else if
            let error = error {
                self = .errorOnly(error)
        } else {
            self = .none
        }
    }
    
    public init(unified: @escaping (MethodResult<ParamType>) -> Void) {
        self = .unified(unified)
    }
    
    public func perform(value: ParamType) {
        switch self {
        case .successOnly(let action):
            action(value)
        case .split(let action, _):
            action(value)
        case .unified(let action):
            action(MethodResult(value))
        default:
            break; // Do nothing
        }
    }
    
    public func perform(error: Error) {
        switch self {
        case .errorOnly(let action):
            action(error)
        case .split(_, let action):
            action(error)
        case .unified(let action):
            action(MethodResult(error: error))
        default:
            break; // Do nothing
        }
    }
    
    public func perform(result: MethodResult<ParamType>) {
        if case .unified(let action) = self {
            action(result)
            return
        }
        do {
            let value = try result.value()
            perform(value: value)
        } catch {
            perform(error: error)
        }
    }
    
    public mutating func setSuccess(_ handler: @escaping (ParamType) -> Void) {
        switch self {
        case .none:
            self = .successOnly(handler)
        case .successOnly(_):
            self = .successOnly(handler)
        case .errorOnly(let errorHandler):
            self = .split(handler, errorHandler)
        case .split(_, let errorHandler):
            self = .split(handler, errorHandler)
        case .unified(let unifiedHandler):
            self = .split(handler, filteredErrorOnly(unifiedHandler))
        }
    }
    
    public mutating func clearSuccess() {
        switch self {
        case .none:
            break; // Do Nothing
        case .successOnly(_):
            self = .none
        case .errorOnly(_):
            break; // Do Nothing
        case .split(_, let errorHandler):
            self = .errorOnly(errorHandler)
        case .unified(let unifiedHandler):
            self = .errorOnly(filteredErrorOnly(unifiedHandler))
        }
    }
    
    public mutating func setError(_ handler: @escaping (Error) -> Void) {
        switch self {
        case .none:
            self = .errorOnly(handler)
        case .successOnly(let successHandler):
            self = .split(successHandler, handler)
        case .errorOnly(_):
            self = .errorOnly(handler)
        case .split(let successHandler, _):
            self = .split(successHandler, handler)
        case .unified(let unifiedHandler):
            self = .split(filteredSuccessOnly(unifiedHandler), handler)
        }
    }
    
    public mutating func clearError() {
        switch self {
        case .none:
            break // Do Nothing
        case .successOnly(_):
            break // Do Nothing
        case .errorOnly(_):
            self = .none
        case .split(let successHandler, _):
            self = .successOnly(successHandler)
        case .unified(let unifiedHandler):
            self = .successOnly(filteredSuccessOnly(unifiedHandler))
        }
    }
    
    public mutating func setUnifiedHandler(_ handler: @escaping (MethodResult<ParamType>) -> Void) {
        self = .unified(handler)
    }
    
    public mutating func clearAll() {
        self = .none
    }
}
