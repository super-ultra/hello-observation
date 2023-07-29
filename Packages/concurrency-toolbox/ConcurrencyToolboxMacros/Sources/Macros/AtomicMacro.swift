import Foundation

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics




public struct AtomicMacro: AccessorMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
              let binding = variableDeclaration.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              binding.accessor == nil
        else { return [] }
        
        guard variableDeclaration.bindingKeyword.tokenKind == .keyword(SwiftSyntax.Keyword.var) else {
            context.diagnose(Diagnostic(
                node: node._syntaxNode,
                message: AtomicMacroDiagnostic.notAVar
            ))
            return []
        }
          
        let getAccessor: AccessorDeclSyntax =
            """
            get {
                _\(raw: identifier).wrappedValue
            }
            """
        
        let setAccessor: AccessorDeclSyntax =
            """
            set {
                _\(raw: identifier).wrappedValue = newValue
            }
            """
        
        return [getAccessor, setAccessor]
    }
    
}

extension AtomicMacro: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let binding = declaration.as(VariableDeclSyntax.self)?.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let type = binding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type.trimmed
        else { return [] }
        
        let rawInitializerClause: String
        
        if let initialValue = binding.initializer?.as(InitializerClauseSyntax.self)?.value {
            rawInitializerClause = " = Atomic(wrappedValue: \(initialValue))"
        } else {
            rawInitializerClause = ""
        }

        return [
            """
            private let _\(raw: identifier): Atomic<\(type)>\(raw: rawInitializerClause)
            """
        ]
    }
    
}




enum AtomicMacroDiagnostic: String, DiagnosticMessage {
    case notAVar
    
    // MARK: - DiagnosticMessage

    var severity: DiagnosticSeverity { return .error }

    var message: String {
        switch self {
        case .notAVar:
            return "Atomic macro can only be applied to a 'var'"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "ConcurrencyToolboxMacros", id: rawValue)
    }
}
