//
//  StaticTimeManager.swift
//  HelloObservability
//
//  Created by Ilya Lobanov on 29.07.2023.
//

import Foundation


actor StaticTimeManager: TimeManager {
    let time: Duration
    let timeStream: AsyncStream<Duration>
    
    init(time: Duration) {
        self.time = time
        self.timeStream = AsyncStream { _ in }
    }
}
