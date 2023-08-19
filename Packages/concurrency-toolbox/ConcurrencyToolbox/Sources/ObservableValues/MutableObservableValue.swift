import Foundation
import Combine
import SwiftUI

public final class MutableObservableValue<Output>: ObservableObject {
    
    public var value: Output {
        get {
            currentValueSubject.value
        }
        set {
            set(newValue)
        }
    }
    
    public let publisher: AnyPublisher<Output, Never>
    
    public init<PublisherT: Publisher>(
        publisher: PublisherT,
        initialValue: Output,
        set: @escaping (Output) -> Void
    ) where PublisherT.Output == Output, PublisherT.Failure == Never {
        self.underlyingPublisher = publisher.eraseToAnyPublisher()
        self.set = set
        self.currentValueSubject = CurrentValueSubject(initialValue)
        self.publisher = currentValueSubject.eraseToAnyPublisher()
        
        self.canceller = underlyingPublisher.sink(
            receiveCompletion: { [weak self] in
                self?.currentValueSubject.send(completion: $0)
            },
            receiveValue: { [weak self] in
                self?.objectWillChange.send()
                self?.currentValueSubject.value = $0
            }
        )
    }
    
    // MARK: - ObservableObject
    
    public let objectWillChange = ObservableObjectPublisher()
    
    // MARK: - Private Properties
    
    private let set: (Output) -> Void
    private let currentValueSubject: CurrentValueSubject<Output, Never>
    private let underlyingPublisher: AnyPublisher<Output, Never>
    private var canceller: AnyCancellable?
}

extension MutableObservableValue {
    
    public convenience init(_ currentValueSubject: CurrentValueSubject<Output, Never>) {
        self.init(
            publisher: currentValueSubject,
            initialValue: currentValueSubject.value,
            set: { currentValueSubject.value = $0 }
        )
    }

    public convenience init(initialValue: Output) {
        self.init(CurrentValueSubject(initialValue))
    }
    
    public convenience init(initialValue: Output, set: @escaping (Output) -> Void) {
        let subject = CurrentValueSubject<Output, Never>(initialValue)
        self.init(
            publisher: subject,
            initialValue: initialValue,
            set: {
                subject.value = $0
                set($0)
            }
        )
    }
}

extension MutableObservableValue {
    
    public func map<U>(transform: @escaping (Output) -> U, inverseTransform: @escaping (U) -> Output) -> MutableObservableValue<U> {
        return MutableObservableValue<U>(
            publisher: underlyingPublisher.map(transform),
            initialValue: transform(value),
            set: { [self] value in
                self.set(inverseTransform(value))
            }
        )
    }
    
}

extension MutableObservableValue {
    
    public func makeImmutable() -> ObservableValue<Output> {
        return ObservableValue<Output>(
            currentValueSubject: currentValueSubject,
            underlyingPublisher: underlyingPublisher,
            publisher: publisher
        )
    }
    
}

extension MutableObservableValue where Output == Bool {
    
    public func toggle() {
        value.toggle()
    }
    
}

extension Binding {
    
    public init(_ observableValue: MutableObservableValue<Value>) {
        self.init(get: { observableValue.value }, set: { observableValue.value = $0 })
    }
    
}

extension MutableObservableValue where Output == Bool {
    
    public func inversed() -> MutableObservableValue<Bool> {
        MutableObservableValue<Bool>(
            publisher: publisher.map(!),
            initialValue: !value,
            set: { [weak self] in self?.value = !$0 }
        )
    }
    
}
