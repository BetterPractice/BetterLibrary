//
//  Binding.swift
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

open class Binding: UniqueObject
{
    public enum BrokenBinding: Error {
        case targetDeallocated
    }
    
    // Invocation holds a reference to Binding object, so binding cannot hold strong reference back
    private weak var invocation: Invocation<AnyKeyPath>! = nil
    public private(set) unowned var origin: Bindable
    public private(set) var keyPath: AnyKeyPath!

    public private(set) var isDestroyed: Bool = false
    public private(set) var isInUse: Bool = false;

    deinit {
        destroy()
    }
    
    public init<TOrigin, TProperty>(origin: TOrigin, originKeyPath: KeyPath<TOrigin, TProperty>, target: @escaping (TProperty) throws -> Void) where TOrigin: Bindable {
        self.origin = origin
        self.keyPath = originKeyPath
        super.init()
        invocation = origin.keyPathDidChange.register { [unowned origin] (changedKeyPath: AnyKeyPath) in
            guard originKeyPath == changedKeyPath else {
                return
            }
            guard self.isInUse == false else {
                return
            }

            self.isInUse = true
            let value = origin[keyPath: originKeyPath]
            do {
                try target(value)
            } catch {
                self.destroy()
            }
            self.isInUse = false
        }
    }
    
    public func activate()
    {
        guard !isDestroyed else {
            print("WARNING: Attempting to activate a destroyed binding.")
            return
        }
        invocation.invoke(keyPath)
    }
    
    public func destroy()
    {
        guard !isDestroyed else {
            print("WARNING: Destruction of binding requested that is already destroyed.")
            return
        }
        origin.keyPathDidChange.remove(invocation: invocation)
        invocation = nil // Clear the reference because the object can't deallocate until the Invocation does
        isDestroyed = true
    }
}

public class ObjectBinding: Binding {
    
    public init<TOrigin, TDestination, TOriginProperty, TDestinationProperty, TValueConverter>(
        origin: TOrigin,
        originKeyPath: KeyPath<TOrigin, TOriginProperty>,
        destination: TDestination,
        destinationKeyPath: ReferenceWritableKeyPath<TDestination, TDestinationProperty>,
        valueConverter: TValueConverter)
        where
        TOrigin: Bindable,
        TDestination: AnyObject,
        TValueConverter: ValueConverter,
        TValueConverter.Source == TOriginProperty,
        TValueConverter.Destination == TDestinationProperty
    {
        super.init(origin: origin,
                   originKeyPath: originKeyPath) { [weak destination] (value) in
                
                    guard let destination = destination else {
                        print("WARNING: Target deallocated.")
                        throw BrokenBinding.targetDeallocated
                    }
                    let convertedValue = valueConverter.convert(value)
                    destination[keyPath: destinationKeyPath] = convertedValue
        }
    }
    
    public init<TOrigin, TDestination, TProperty>(
        origin: TOrigin, originKeyPath:
        KeyPath<TOrigin, TProperty>,
        destination: TDestination,
        destinationKeyPath: ReferenceWritableKeyPath<TDestination, TProperty>)
        where
        TOrigin: Bindable,
        TDestination: AnyObject
    {
        super.init(origin: origin,
                   originKeyPath: originKeyPath) { [weak destination] (value) in
                    
                    guard let destination = destination else {
                        print("WARNING: Target deallocated.")
                        throw BrokenBinding.targetDeallocated
                    }
                    destination[keyPath: destinationKeyPath] = value

        }
    }
}

public class EventBinding<TParam>: Binding {
    
    public init<TOrigin, TDestination>(
        origin: TOrigin,
        orignKeyPath: KeyPath<TOrigin, Invocation<TParam>?>,
        destination: TDestination,
        destinationKeyPath: KeyPath<TDestination, Event<TParam>>)
        where
        TOrigin: Bindable,
        TDestination: AnyObject
    {
        var lastValue: Invocation<TParam>? = nil
        super.init(origin: origin, originKeyPath: orignKeyPath) { [weak destination] (value) in
            guard let destination = destination else {
                print("WARNING: Target deallocated.")
                throw BrokenBinding.targetDeallocated
            }
            let event = destination[keyPath: destinationKeyPath]
            
            if let lastValue = lastValue {
                event.remove(invocation: lastValue)
            }
            lastValue = value
            if let value = value {
                event.register(invocation: value)
            }
        }
    }
}
