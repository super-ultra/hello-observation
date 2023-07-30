import Foundation
import Observation


@MainActor
protocol TimerViewModel: Observable {
    var time: Duration { get }
}


@Observable
final class DefaultTimerViewModel: TimerViewModel {
    
    init(timeManager: TimeManager) {
        self.time = timeManager.atomicTime
        self.timeManager = timeManager
        
        setup()
    }
    
    // MARK: - TimerViewModel
    
    private(set) var time: Duration
    
    // MARK: - Private
    
    private let timeManager: TimeManager
    
    private func setup() {
        Task {
            for await newTime in await timeManager.timeStream {
                time = newTime
            }
        }
    }
}


extension DefaultTimerViewModel {
    
    static func `static`(time: Duration) -> DefaultTimerViewModel {
        DefaultTimerViewModel(timeManager: StaticTimeManager(time: time))
    }
    
    static func system() -> DefaultTimerViewModel {
        DefaultTimerViewModel(timeManager: SystemTimeManager())
    }
    
}
