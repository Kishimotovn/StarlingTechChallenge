import Foundation
import UIKit

public protocol IdentifiedCell {
    static var identifier: String { get }
}

public extension IdentifiedCell {
    static var identifier: String {
        return String(describing: Self.self)
    }
}


