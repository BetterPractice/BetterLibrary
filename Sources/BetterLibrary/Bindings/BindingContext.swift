//
//  BindingContext.swift
//  BetterLibrary Bindings
//
//  Created by Holly Schilling on 3/4/18.
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

public protocol BindingContext
{
    var dataContext: Any? { get set }
    
    func dataContextDidChange()
}

extension BindingContext
{
    public func setObservableCollection<T>(storage: inout ObservableCollection<T>, value: ObservableCollection<T>, didChange: Invocation<CollectionChange>, invokeDidChangeNow: Bool = true)
    {
        storage.didChangeCollection.remove(invocation: didChange)
        storage = value
        storage.didChangeCollection.register(invocation: didChange)
        
        if invokeDidChangeNow {
            didChange.invoke(.reset)
        }
    }
    
    public func setObservableCollection<T>(storage: inout ObservableCollection<T>?, value: ObservableCollection<T>?, didChange: Invocation<CollectionChange>, invokeDidChangeNow: Bool = true)
    {
        if let oldValue = storage {
            oldValue.didChangeCollection.remove(invocation: didChange)
        }
        storage = value
        if let newValue = storage {
            newValue.didChangeCollection.register(invocation: didChange)
        }
        if invokeDidChangeNow {
            didChange.invoke(.reset)
        }
    }
}
