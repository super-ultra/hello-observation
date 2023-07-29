import XCTest
import SwiftSyntaxMacrosTestSupport
import SwiftSyntaxMacros

@testable import ConcurrencyToolboxMacros


private let testMacros: [String: Macro.Type] = [
    "Atomic": AtomicMacro.self
]


final class AtomicMacroTests: XCTestCase {
    
    func testExpansionWithInitializerClause() throws {
        assertMacroExpansion(
            """
            @Atomic
            var id: String = "12"
            """,
            expandedSource: """
                
                var id: String = "12" {
                    get {
                        _id.wrappedValue
                    }
                    set {
                        _id.wrappedValue = newValue
                    }
                }
                private let _id: Atomic<String> = Atomic(wrappedValue: "12")
                """,
            macros: testMacros
        )
    }
    
    func testExpansionWithoutInitializerClause() throws {
        assertMacroExpansion(
            """
            @Atomic
            var id: String
            """,
            expandedSource: """
                
                var id: String {
                    get {
                        _id.wrappedValue
                    }
                    set {
                        _id.wrappedValue = newValue
                    }
                }
                private let _id: Atomic<String>
                """,
            macros: testMacros
        )
    }
    
}
