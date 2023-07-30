import Foundation
import Observation


@MainActor
protocol ObservationTimerViewModel: Observable {
    var time: Duration { get }
}


@Observable
final class ObservationTimerViewModelImpl: ObservationTimerViewModel {
    
    init(timeManager: TimeManager) {
        self.timeManager = timeManager
        
        setup()
    }
    
    // MARK: - ObservationTimerViewModel
    
    private(set) var time: Duration = .zero
    
    // MARK: - Private
    
    private let timeManager: TimeManager
    
    private func setup() {
        Task {
            time = await timeManager.time
            for await newTime in await timeManager.timeStream {
                time = newTime
            }
        }
    }
}


extension ObservationTimerViewModelImpl {
    
    static func `static`(time: Duration) -> ObservationTimerViewModelImpl {
        ObservationTimerViewModelImpl(timeManager: StaticTimeManager(time: time))
    }
    
    static func system() -> ObservationTimerViewModelImpl {
        ObservationTimerViewModelImpl(timeManager: SystemTimeManager())
    }
    
}
