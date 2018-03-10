//
//  ObservableCollection.swift
//  BetterLibrary Bindings
//
//  Created by Holly Schilling on 3/3/18.
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

public enum CollectionChange
{
    case remove(Int)
    case add(Int)
    case move(Int, Int)
    case swap(Int, Int)
    case replace(Int)
    case reset
}

open class ObservableCollection<Element>: ExpressibleByArrayLiteral
{
    public let didChangeCollection: Event<CollectionChange> = Event()
    
    fileprivate var items: [Element] = []
    
    public required init() { }
    
    public required init(arrayLiteral elements: Element...)
    {
        for element in elements {
            items.append(element)
        }
    }

    public required init<S: Sequence>(_ sequence: S) where S.Iterator.Element == Element
    {
        for element in sequence {
            items.append(element)
        }
    }
    
    open func append(_ newElement: Element)
    {
        items.append(newElement)
        didChangeCollection.invoke(param: .add(items.count - 1))
    }
    
    open func remove(at index: Int) -> Element
    {
        let element = items.remove(at: index)
        didChangeCollection.invoke(param: .remove(index))
        return element
    }
    
    open func insert(_ newElement: Element, at index: Int)
    {
        items.insert(newElement, at: index)
        didChangeCollection.invoke(param: .add(index))
    }
    
    open func swapAt(_ first: Int, _ second: Int)
    {
        items.swapAt(first, second)
        didChangeCollection.invoke(param: .swap(first, second))
    }
    
    open func move(from source: Int, to destination: Int)
    {
        let item = items.remove(at: source)
        items.insert(item, at: destination)
        didChangeCollection.invoke(param: .move(source, destination))
    }
}

extension ObservableCollection: Sequence
{
    public typealias Iterator =  IndexingIterator<Array<Element>>
    
    open func makeIterator() -> Iterator
    {
        return items.makeIterator()
    }
}

extension ObservableCollection: Collection
{
    public typealias Index = Int
    
    open var startIndex: Index
    {
        return items.startIndex
    }
    
    open var endIndex: Index
    {
        return items.endIndex
    }
    
    open subscript (position: Index) -> Iterator.Element
    {
        get { return items[position] }
        set
        {
            items[position] = newValue
            didChangeCollection.invoke(param: .replace(position))
        }
    }
    
    open func index(after i: Index) -> Index
    {
        return items.index(after: i)
    }
}

