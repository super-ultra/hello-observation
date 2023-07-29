import Foundation


@attached(peer, names: prefixed(_))
@attached(accessor)
public macro Atomic() = #externalMacro(
    module: "ConcurrencyToolboxMacros",
    type: "AtomicMacro"
)

