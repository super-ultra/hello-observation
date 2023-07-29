import Foundation


protocol TimeManager: Actor {
    nonisolated var time: Duration { get }
    var timeStream: AsyncStream<Duration> { get }
}
