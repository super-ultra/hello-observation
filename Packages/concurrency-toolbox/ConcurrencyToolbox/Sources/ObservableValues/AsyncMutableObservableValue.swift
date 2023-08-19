import Foundation
import Combine

public final class AsyncMutableObservableValue<Output, Failure: Error>: ObservableObject {

    public typealias SetCompletion = (Result<Output, Failure>) -> Void
    public typealias SetHandler = (_ value: Output, _ completion: @escaping SetCompletion) -> Void

    public var value: Output {
        currentValueSubject.value
    }

    public let publisher: AnyPublisher<Output, Never>

    public init<PublisherT: Publisher>(
        publisher: PublisherT,
        initialValue: Output,
        set: @escaping SetHandler
    ) where PublisherT.Output == Output, PublisherT.Failure == Never {
        self.underlyingPublisher = publisher.eraseToAnyPublisher()
        self.currentValueSubject = CurrentValueSubject(initialValue)
        self.set = set
        self.publisher = currentValueSubject.eraseToAnyPublisher()
        
        canceller = underlyingPublisher.sink(
            receiveCompletion: { [weak self] in
                self?.currentValueSubject.send(completion: $0)
            },
            receiveValue: { [weak self] in
                self?.objectWillChange.send()
                self?.currentValueSubject.value = $0
            }
        )
    }

    public func set(_ value: Output, completion: SetCompletion? = nil) {
        self.set(value) { result in
            completion?(result)
        }
    }
    
    // MARK: - ObservableObject
    
    public let objectWillChange = ObservableObjectPublisher()

    // MARK: - Private

    private let currentValueSubject: CurrentValueSubject<Output, Never>
    private let underlyingPublisher: AnyPublisher<Output, Never>
    private let set: SetHandler
    private var canceller: AnyCancellable?
}


// MARK: - Convenience

extension AsyncMutableObservableValue {

    public convenience init(subject: CurrentValueSubject<Output, Never>, set: @escaping SetHandler) {
        self.init(publisher: subject, initialValue: subject.value, set: set)
    }

    public static func constant(_ value: Output) -> AsyncMutableObservableValue {
        let subject = CurrentValueSubject<Output, Never>(value)
        return AsyncMutableObservableValue(
            publisher: subject,
            initialValue: value,
            set: { [subject] value, completion in
                subject.value = value
                completion(.success(value))
            }
        )
    }

}


extension AsyncMutableObservableValue where Output == Bool {

    public func toggle(completion: SetCompletion? = nil) {
        set(!value, completion: completion)
    }

}
