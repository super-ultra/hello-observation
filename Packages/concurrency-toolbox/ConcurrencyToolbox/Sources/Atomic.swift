//
//  Atomic.swift
//  
//
//  Created by Ilya Lobanov on 30.07.2023.
//

import Foundation

// @propertyWrapper
public final class Atomic<T>: @unchecked Sendable {

    public init(value: T, lock: NSLocking) {
        self.lock = lock
        self.value = value
    }

    // MARK: - @propertyWrapper
    
    public var wrappedValue: T {
        get {
            lock.perform { value }
        }
        set {
            lock.perform { value = newValue }
        }
    }
    
    public convenience init(wrappedValue: T) {
        self.init(value: wrappedValue, lock: NSRecursiveLock())
    }
    
    // MARK: - Private
    
    private let lock: NSLocking
    private var value: T
    
}


extension NSLocking {
    
    @discardableResult
    fileprivate func perform<T>(_ block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
    
}
