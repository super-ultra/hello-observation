//
//  SystemTimeManager.swift
//  HelloObservability
//
//  Created by Ilya Lobanov on 29.07.2023.
//

import Foundation
import AsyncAlgorithms


actor SystemTimeManager: TimeManager {
    
    init() {
        Task {
            await start()
        }
    }
    
    // MARK: - TimeManager
    
    private(set) nonisolated var time: Duration {
        get {
            _time.wrappedValue
        }
        set {
            _time.wrappedValue = newValue
        }
    }
    
    private(set) lazy var timeStream = AsyncStream<Duration> { continuation in
        timeStreamContinuation = continuation
    }
    
    // MARK: - Private
    
    private var timeStreamContinuation: AsyncStream<Duration>.Continuation? = nil
    private let step: Duration = .seconds(1)
    private let _time: Atomic<Duration> = Atomic(wrappedValue: .zero)
    
    private func start() async {
        let start = SuspendingClock.Instant.now
        for await newTime in AsyncTimerSequence.repeating(every: step) {
            time = start.duration(to: newTime)
            timeStreamContinuation?.yield(time)
        }
    }

}
