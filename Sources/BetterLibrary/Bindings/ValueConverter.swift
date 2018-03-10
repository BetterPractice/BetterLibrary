//
//  ValueConverter.swift
//  BetterLibrary Bindings
//
//  Created by Holly Schilling on 2/18/18.
//  Copyright 2018 Better Practice Solutions
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

public protocol ValueConverter
{
    associatedtype Source
    associatedtype Destination
    
    func convert(_ value: Source) -> Destination
}

public protocol ReversableValueConverter : ValueConverter
{
    func convertBack(_ value: Destination) -> Source
}

public struct ReversedValueConverter<TChild: ReversableValueConverter>: ReversableValueConverter
{
    var childValueConverter: TChild
    
    init(_ child: TChild)
    {
        childValueConverter = child
    }
    
    public func convert(_ value: TChild.Destination) -> TChild.Source {
        return childValueConverter.convertBack(value)
    }
    
    public func convertBack(_ value: TChild.Source) -> TChild.Destination {
        return childValueConverter.convert(value)
    }
}
