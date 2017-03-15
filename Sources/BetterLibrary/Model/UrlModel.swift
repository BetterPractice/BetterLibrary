//
//  UrlModel.swift
//  BetterLibrary Model
//
//  Created by Holly Schilling on 3/15/17.
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

extension Model {

    public var url: URL? {
        return value as? URL
    }
    
    public var isUrl: Bool {
        return value is URL
    }

    public var convertedUrl: URL? {
        if let url = url {
            return url
        } else if let string = string {
            return URL(string: string)
        } else {
            return nil
        }
    }
    
    public func urlValue() throws -> URL {
        return try impliedUnwrap()
    }
    
    public func convertedUrlValue() throws -> URL {
        if let url = url {
            return url
        } else if let string = string {
            if let url = URL(string: string) {
                return url
            } else {
                throw ModelError.notConvertable
            }
        } else if value == nil {
            throw ModelError.nullObject
        } else {
            throw ModelError.wrongType
        }
    }
}
