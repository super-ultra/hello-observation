import Foundation


// TODO: Remove - https://github.com/apple/swift/issues/63730
#if os(iOS)

@attached(accessor)
//@attached(peer, names: prefixed(_))
public macro Atomic() = #externalMacro(
    module: "ConcurrencyToolboxMacros",
    type: "AtomicMacro"
)

#else

@attached(accessor)
@attached(peer, names: prefixed(_))
public macro Atomic() = #externalMacro(
    module: "ConcurrencyToolboxMacros",
    type: "AtomicMacro"
)

#endif
