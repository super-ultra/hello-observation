import Foundation
import Combine

public final class ObservableValue<Output>: ObservableObject {
    
    public var value: Output {
        currentValueSubject.value
    }
    
    public let publisher: AnyPublisher<Output, Never>
    
    public convenience init<PublisherT: Publisher>(
        publisher: PublisherT,
        initialValue: Output
    ) where PublisherT.Output == Output, PublisherT.Failure == Never {
        let underlyingPublisher = publisher.eraseToAnyPublisher()
        let currentValueSubject = CurrentValueSubject<Output, Never>(initialValue)
        let publisher = currentValueSubject.eraseToAnyPublisher()
        
        self.init(
            currentValueSubject: currentValueSubject,
            underlyingPublisher: underlyingPublisher,
            publisher: publisher
        )
    }
    
    // MARK: - ObservableObject
    
    public let objectWillChange = ObservableObjectPublisher()
    
    // MARK: - Internal
    
    internal init(
        currentValueSubject: CurrentValueSubject<Output, Never>,
        underlyingPublisher: AnyPublisher<Output, Never>,
        publisher: AnyPublisher<Output, Never>
    ) {
        self.currentValueSubject = currentValueSubject
        self.underlyingPublisher = underlyingPublisher
        self.publisher = publisher
        
        canceller = underlyingPublisher.sink(
            receiveCompletion: { [weak self] in
                self?.currentValueSubject.send(completion: $0)
            },
            receiveValue: { [weak self] in
                self?.objectWillChange.send()
                self?.currentValueSubject.send($0)
            }
        )
    }
    
    // MARK: - Private
    
    private let currentValueSubject: CurrentValueSubject<Output, Never>
    private let underlyingPublisher: AnyPublisher<Output, Never>
    private var canceller: AnyCancellable?
}

extension ObservableValue {
    
    public func map<U>(_ transform: @escaping (Output) -> U) -> ObservableValue<U> {
        return ObservableValue<U>(publisher: underlyingPublisher.map(transform), initialValue: transform(value))
    }
    
    public func combineLatest<U>(_ another: ObservableValue<U>) -> ObservableValue<(Output, U)> {
        return ObservableValue<(Output, U)>(
            publisher: underlyingPublisher.combineLatest(another.underlyingPublisher),
            initialValue: (self.value, another.value)
        )
    }
    
    // swiftlint:disable large_tuple
    public func combineLatest<U, W>(_ another1: ObservableValue<U>, _ another2: ObservableValue<W>) -> ObservableValue<(Output, U, W)> {
        return ObservableValue<(Output, U, W)>(
            publisher: underlyingPublisher.combineLatest(another1.underlyingPublisher, another2.underlyingPublisher),
            initialValue: (self.value, another1.value, another2.value)
        )
    }

    public func combineLatest<U, W, X>(
        _ another1: ObservableValue<U>,
        _ another2: ObservableValue<W>,
        _ another3: ObservableValue<X>
    ) -> ObservableValue<(Output, U, W, X)> {
        return ObservableValue<(Output, U, W, X)>(
            publisher: underlyingPublisher.combineLatest(
                another1.underlyingPublisher,
                another2.underlyingPublisher,
                another3.underlyingPublisher
            ),
            initialValue: (self.value, another1.value, another2.value, another3.value)
        )
    }
    
    public func compactMap<U>(initialValue: U, _ transform: @escaping (Output) -> U?) -> ObservableValue<U> {
        return ObservableValue<U>(publisher: underlyingPublisher.compactMap(transform), initialValue: initialValue)
    }
    
}

extension ObservableValue {
    
    public convenience init(_ currentValueSubject: CurrentValueSubject<Output, Never>) {
        self.init(
            publisher: currentValueSubject,
            initialValue: currentValueSubject.value
        )
    }
    
    public static func constant(_ value: Output) -> ObservableValue {
        return ObservableValue(CurrentValueSubject(value))
    }

}

extension ObservableValue where Output: Equatable {

    public var prependingValuePublisher: AnyPublisher<Output, Never> {
        return publisher.prepend(value).removeDuplicates().eraseToAnyPublisher()
    }
    
    public func removeDuplicates() -> ObservableValue<Output> {
        return ObservableValue(
            publisher: underlyingPublisher.removeDuplicates(),
            initialValue: self.value
        )
    }
}
