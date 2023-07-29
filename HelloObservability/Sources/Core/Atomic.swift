//
//  Atomic.swift
//  HelloObservability
//
//  Created by Ilya Lobanov on 30.07.2023.
//

import Foundation


@propertyWrapper
final class Atomic<T>: @unchecked Sendable {

    init(value: T, lock: NSLocking) {
        self.lock = lock
        self.value = value
    }

    // MARK: - @propertyWrapper
    
    var wrappedValue: T {
        get { lock.perform { value } }
        set { lock.perform { value = newValue } }
    }
    
    convenience init(wrappedValue: T) {
        self.init(value: wrappedValue, lock: NSRecursiveLock())
    }
    
    // MARK: - Private
    
    private let lock: NSLocking
    private var value: T
    
}


extension NSLocking {
    @discardableResult
    func perform<T>(_ block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}
