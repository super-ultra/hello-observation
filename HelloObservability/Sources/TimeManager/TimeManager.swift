import Foundation


protocol TimeManager: Actor {
    var time: Duration { get }
    var timeStream: AsyncStream<Duration> { get }
}
