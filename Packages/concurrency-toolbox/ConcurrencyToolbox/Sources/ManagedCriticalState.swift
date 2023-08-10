import Darwin


struct ManagedCriticalState<State> {
    private final class LockedBuffer: ManagedBuffer<State, Lock.Primitive> {
        deinit {
            withUnsafeMutablePointerToElements { Lock.deinitialize($0) }
        }
    }
    
    private let buffer: ManagedBuffer<State, Lock.Primitive>
    
    init(_ initial: State) {
        buffer = LockedBuffer.create(minimumCapacity: 1) { buffer in
            buffer.withUnsafeMutablePointerToElements { Lock.initialize($0) }
            return initial
        }
    }
    
    func withCriticalRegion<R>(_ critical: (inout State) throws -> R) rethrows -> R {
        try buffer.withUnsafeMutablePointers { header, lock in
            Lock.lock(lock)
            defer { Lock.unlock(lock) }
            return try critical(&header.pointee)
        }
    }
}


extension ManagedCriticalState: @unchecked Sendable where State: Sendable { }




private struct Lock {
    typealias Primitive = os_unfair_lock
    
    typealias PlatformLock = UnsafeMutablePointer<Primitive>
    
    static func allocate() -> Lock {
        let platformLock = PlatformLock.allocate(capacity: 1)
        initialize(platformLock)
        return Lock(platformLock)
    }
    
    func deinitialize() {
        Lock.deinitialize(platformLock)
    }
    
    func lock() {
        Lock.lock(platformLock)
    }
    
    func unlock() {
        Lock.unlock(platformLock)
    }
    
    /// Acquire the lock for the duration of the given block.
    ///
    /// This convenience method should be preferred to `lock` and `unlock` in
    /// most situations, as it ensures that the lock will be released regardless
    /// of how `body` exits.
    ///
    /// - Parameter body: The block to execute while holding the lock.
    /// - Returns: The value returned by the block.
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        self.lock()
        defer {
            self.unlock()
        }
        return try body()
    }
    
    // specialise Void return (for performance)
    func withLockVoid(_ body: () throws -> Void) rethrows -> Void {
        try self.withLock(body)
    }
    
    // MARK: - File Private
    
    fileprivate static func initialize(_ platformLock: PlatformLock) {
        platformLock.initialize(to: os_unfair_lock())
    }
    
    fileprivate static func deinitialize(_ platformLock: PlatformLock) {
        platformLock.deinitialize(count: 1)
    }
    
    fileprivate static func lock(_ platformLock: PlatformLock) {
        os_unfair_lock_lock(platformLock)
    }
    
    fileprivate static func unlock(_ platformLock: PlatformLock) {
        os_unfair_lock_unlock(platformLock)
    }
    
    // MARK: - Private
    
    private let platformLock: PlatformLock
    
    private init(_ platformLock: PlatformLock) {
        self.platformLock = platformLock
    }
}
