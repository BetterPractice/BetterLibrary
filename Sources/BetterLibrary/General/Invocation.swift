//
//  Invocation.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 4/13/17.
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

public class Invocation<TParam>: UniqueObject
{
    private var block: (TParam) -> Void
    
    public func invoke(_ param: TParam)
    {
        block(param);
    }
    
    public init(_ lambda: @escaping (TParam) -> Void)
    {
        block = lambda
    }
    
    public convenience init<T: AnyObject>(weakObject: T, method: @escaping (T) -> (TParam) -> Void)
    {
        let block = Invocation.CreateLambda(from: weakObject, method: method)
        self.init(block)
    }
    
    public class func CreateLambda<T: AnyObject>(from weakObject: T, method: @escaping (T) -> (TParam) -> Void) -> (TParam) -> Void
    {
        return { [weak weakObject] (param) in
            guard let obj = weakObject else {
                return
            }
            method(obj)(param)
        }
    }
}
