import Foundation

public struct AppError: Error {
    public static var typeIdentifier: String {
        let type = "\(self)"
        return type.split(separator: ".").last.flatMap(String.init) ?? type
    }

    public struct ErrorSource: Sendable, CustomStringConvertible {
        /// File in which this location exists.
        public var file: String
        
        /// Function in which this location exists.
        public var function: String
        
        /// Line number this location belongs to.
        public var line: UInt
        
        /// Number of characters into the line this location starts at.
        public var column: UInt
        
        /// Optional start/end range of the source.
        public var range: Range<UInt>?
        
        /// Creates a new `SourceLocation`
        public init(
            file: String,
            function: String,
            line: UInt,
            column: UInt,
            range: Range<UInt>? = nil
        ) {
            self.file = file
            self.function = function
            self.line = line
            self.column = column
            self.range = range
        }

        public var description: String {
            var infos = [String]()
            infos.append("File: \(self.file)")
            infos.append("Function: \(self.function)")
            infos.append("Line: \(self.line)")
            return infos.joined(separator: ", ")
        }
    }

    public enum Value {
        case unknown
    }
    
    var identifier: String {
        switch self.value {
        case .unknown:
            return "unknown"
        }
    }
    
    var reason: String {
        switch self.value {
        case .unknown:
            return "Unknown Error Occured."
        }
    }
    
    var value: Value
    var source: ErrorSource?
    
    public init(
        _ value: Value,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.value = value
        self.source = .init(
            file: file,
            function: function,
            line: line,
            column: column
        )
    }
}

extension AppError: LocalizedError {
    public var fullIdentifier: String {
        return Self.typeIdentifier + "." + self.identifier
    }

    public var errorDescription: String? {
        var infos = ["\(self.fullIdentifier): \(self.reason)"]
        
        #if DEBUG
        if let source {
            infos.append(source.description)
        }
        #endif
        
        return infos.joined(separator: " | ")
    }
}
