import Foundation


protocol TimeManager: Actor {
    nonisolated var atomicTime: Duration { get }
    var time: Duration { get }
    var timeStream: AsyncStream<Duration> { get }
}
