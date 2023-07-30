import Foundation
import Combine


@MainActor
protocol CombineTimerViewModel: ObservableObject {
    var time: Duration { get }
}


final class CombineTimerViewModelImpl: CombineTimerViewModel {
    
    init(timeManager: TimeManager) {
        self.time = timeManager.atomicTime
        self.timeManager = timeManager
        
        setup()
    }
    
    // MARK: - ObservationTimerViewModel
    
    @Published
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


extension CombineTimerViewModelImpl {
    
    static func `static`(time: Duration) -> CombineTimerViewModelImpl {
        CombineTimerViewModelImpl(timeManager: StaticTimeManager(time: time))
    }
    
    static func system() -> CombineTimerViewModelImpl {
        CombineTimerViewModelImpl(timeManager: SystemTimeManager())
    }
    
}
