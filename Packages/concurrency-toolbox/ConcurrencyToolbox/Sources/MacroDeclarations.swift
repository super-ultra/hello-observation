import Foundation

@attached(accessor)
@attached(peer, names: prefixed(_))
public macro Atomic() = #externalMacro(
    module: "ConcurrencyToolboxMacros",
    type: "AtomicMacro"
)
