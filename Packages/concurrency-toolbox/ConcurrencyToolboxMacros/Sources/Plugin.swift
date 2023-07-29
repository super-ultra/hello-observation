import SwiftCompilerPlugin
import SwiftSyntaxMacros


@main
struct ConcurrencyToolboxPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AtomicMacro.self,
    ]
}
