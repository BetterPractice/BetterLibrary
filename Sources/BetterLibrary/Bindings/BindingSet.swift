//
//  BindingSet.swift
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

public class BindingSet<TOrigin> where TOrigin: Bindable
{
    public private(set) weak var origin: TOrigin?
    
    public private(set) var forwardBindings: Set<Binding> = []
    public private(set) var reverseBindings: Set<Binding> = []

    public init(origin: TOrigin)
    {
        self.origin = origin
    }
    
    deinit {
        forwardBindings.forEach { $0.destroy() }
        reverseBindings.forEach { $0.destroy() }
    }
    
    // MARK: - Functional Bindings
    
    public func bindFunctional<TProperty>(
        originKeyPath: KeyPath<TOrigin, TProperty>,
        target: @escaping (TProperty) -> Void)
    {
        guard let origin = origin else {
            print("WARNING: Origin is deallocated")
            return
        }
        let binding = Binding(
            origin: origin,
            originKeyPath: originKeyPath,
            target: target)
        forwardBindings.insert(binding)
    }
    
    public func bindFunctional<TOriginProperty, TDestinationParam, TValueConverter>(
        originKeyPath: KeyPath<TOrigin, TOriginProperty>,
        valueConverter: TValueConverter,
        target: @escaping (TDestinationParam) -> Void)
    where
        TValueConverter: ValueConverter,
        TValueConverter.Source == TOriginProperty,
        TValueConverter.Destination == TDestinationParam
    {
        bindFunctional(originKeyPath: originKeyPath) { (value) in
            let convertedValue = valueConverter.convert(value)
            target(convertedValue)
        }
    }

    public func bindFunctional<TDestination, TProperty>(originKeyPath: KeyPath<TOrigin, TProperty>, destination: TDestination, method: @escaping (TDestination) -> (TProperty) -> Void)
        where TDestination: AnyObject
    {

        bindFunctional(
            originKeyPath: originKeyPath,
            target: Invocation.CreateLambda(from: destination, method: method))
    }
    
    public func bindFunctional<TOriginProperty, TDestination, TDestinationParam, TValueConverter>(
        originKeyPath: KeyPath<TOrigin, TOriginProperty>,
        valueConverter: TValueConverter,
        destination: TDestination, method: @escaping (TDestination) -> (TDestinationParam) -> Void)
    where
        TDestination: AnyObject,
        TValueConverter: ValueConverter,
        TValueConverter.Source == TOriginProperty,
        TValueConverter.Destination == TDestinationParam
    {
        bindFunctional(
            originKeyPath: originKeyPath,
            valueConverter: valueConverter,
            target: Invocation.CreateLambda(from: destination, method: method))
    }
    
    //MARK: - EventBinding
    
    public func bindEvent<TParam, TDestination>(originKeyPath: KeyPath<TOrigin, Invocation<TParam>?>, destination: TDestination, destinationKeyPath: KeyPath<TDestination, Event<TParam>>)
        where TDestination: AnyObject
    {
        guard let origin = origin else {
            print("WARNING: Origin is deallocated")
            return
        }

        let binding = EventBinding(
            origin: origin,
            orignKeyPath: originKeyPath,
            destination: destination,
            destinationKeyPath: destinationKeyPath)
        forwardBindings.insert(binding)
    }
    
    //MARK: - One-way Bindings
    
    public func bindOneWay<TDestination, TProperty>(originKeyPath: KeyPath<TOrigin, TProperty>, destination: TDestination, destinationKeyPath: ReferenceWritableKeyPath<TDestination, TProperty>)
        where TDestination: AnyObject
    {
        guard let origin = origin else {
            print("WARNING: Origin is deallocated")
            return
        }
        let binding = ObjectBinding(
            origin: origin,
            originKeyPath: originKeyPath,
            destination: destination,
            destinationKeyPath: destinationKeyPath)
        forwardBindings.insert(binding)
    }
    
    public func bindOneWay<TDestination, TDestinationProperty, TOriginProperty, TValueConverter>(originKeyPath: KeyPath<TOrigin, TOriginProperty>, destination: TDestination, destinationKeyPath: ReferenceWritableKeyPath<TDestination, TDestinationProperty>, valueConverter: TValueConverter) where
        TDestination: AnyObject,
        TValueConverter: ValueConverter,
        TValueConverter.Source == TOriginProperty,
        TValueConverter.Destination == TDestinationProperty
    {
        guard let origin = origin else {
            print("WARNING: Origin is deallocated")
            return
        }
        let binding = ObjectBinding(
            origin: origin,
            originKeyPath: originKeyPath,
            destination: destination,
            destinationKeyPath: destinationKeyPath,
            valueConverter: valueConverter)
        forwardBindings.insert(binding)
    }
    
    // MARK: - Two-way Bindings
    
    public func bindTwoWay<TDestination, TProperty>(originKeyPath: ReferenceWritableKeyPath<TOrigin, TProperty>, destination: TDestination, destinationKeyPath: ReferenceWritableKeyPath<TDestination, TProperty>)  where TDestination: Bindable
    {
        guard let origin = origin else {
            print("WARNING: Origin is deallocated")
            return
        }
        let forward = ObjectBinding(
            origin: origin,
            originKeyPath: originKeyPath,
            destination: destination,
            destinationKeyPath: destinationKeyPath)
        forwardBindings.insert(forward)
        
        let reverse = ObjectBinding(
            origin: destination,
            originKeyPath: destinationKeyPath,
            destination: origin,
            destinationKeyPath: originKeyPath)
        reverseBindings.insert(reverse)
    }
    
    public func bindTwoWay<TDestination, TDestinationProperty, TOriginProperty, TValueConverter>(originKeyPath: ReferenceWritableKeyPath<TOrigin, TOriginProperty>, destination: TDestination, destinationKeyPath: ReferenceWritableKeyPath<TDestination, TDestinationProperty>, valueConverter: TValueConverter) where
        TDestination: Bindable,
        TValueConverter: ReversableValueConverter,
        TValueConverter.Source == TOriginProperty,
        TValueConverter.Destination == TDestinationProperty
    {
        guard let origin = origin else {
            print("WARNING: Origin is deallocated")
            return
        }
        let forward = ObjectBinding(
            origin: origin,
            originKeyPath: originKeyPath,
            destination: destination,
            destinationKeyPath: destinationKeyPath,
            valueConverter: valueConverter)
        forwardBindings.insert(forward)
        
        let reverse = ObjectBinding(
            origin: destination,
            originKeyPath: destinationKeyPath,
            destination: origin,
            destinationKeyPath: originKeyPath,
            valueConverter: ReversedValueConverter(valueConverter))
        reverseBindings.insert(reverse)
    }

    // MARK: - Other Methods
    
    public func activate()
    {
        for aBinding in forwardBindings {
            aBinding.activate()
        }
    }
    
    
    
    
}
