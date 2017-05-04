//
//  Queue.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 5/3/17.
//
//

import Foundation
import Dispatch

public protocol Queue {
    func enqueue(_ handler: @escaping () -> Void)
}

extension OperationQueue: Queue {
    
    public func enqueue(_ handler: @escaping () -> Void) {
        addOperation(handler)
    }
}

extension DispatchQueue: Queue {
    
    public func enqueue(_ handler: @escaping () -> Void) {
        async(execute: handler)
    }
}
