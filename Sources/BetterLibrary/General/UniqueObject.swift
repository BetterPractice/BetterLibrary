//
//  UniqueObject.swift
//  BindingWork
//
//  Created by Holly Schilling on 3/4/18.
//  Copyright © 2018 Holly Schilling. All rights reserved.
//

import Foundation

open class UniqueObject: Comparable, Hashable
{
    open static func ==(lhs: UniqueObject, rhs: UniqueObject) -> Bool
    {
        return lhs === rhs
    }
    
    open static func <(lhs: UniqueObject, rhs: UniqueObject) -> Bool
    {
        let l = ObjectIdentifier(lhs)
        let r = ObjectIdentifier(rhs)
        return l < r
    }
    
    open var hashValue: Int {
        let identifier = ObjectIdentifier(self)
        return identifier.hashValue
    }
}
