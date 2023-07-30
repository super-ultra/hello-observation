//
//  SystemTimeManager.swift
//  HelloObservability
//
//  Created by Ilya Lobanov on 29.07.2023.
//

import Foundation
import AsyncAlgorithms
import ConcurrencyToolbox


actor SystemTimeManager: TimeManager {
    
    init() {
        Task {
            await start()
        }
    }
    
    // MARK: - TimeManager
    
    @Atomic
    private(set) nonisolated var atomicTime: Duration = .zero
    
    // TODO: Remove - https://github.com/apple/swift/issues/63730
    private let _atomicTime: Atomic<Duration> = Atomic(wrappedValue: .zero)
    
    private(set) var time: Duration = .zero
    
    private(set) lazy var timeStream = AsyncStream<Duration> { continuation in
        timeStreamContinuation = continuation
    }
    
    // MARK: - Private
    
    private var timeStreamContinuation: AsyncStream<Duration>.Continuation? = nil
    private let step: Duration = .seconds(1)
    
    private func start() async {
        let start = SuspendingClock.Instant.now
        for await newTime in AsyncTimerSequence.repeating(every: step) {
            time = start.duration(to: newTime)
            atomicTime = time
            timeStreamContinuation?.yield(time)
        }
    }

}
