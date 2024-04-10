import Foundation
import UIKit
import SwiftUI

public struct UIKitPreviewContainer<T: UIView>: UIViewRepresentable {
    let view: T
    public init(_ viewBuilder: @escaping () -> T) {
        view = viewBuilder()
    }
    
    // MARK: - UIViewRepresentable
    public func makeUIView(context: Context) -> T {
        return view
        
    }

    public func updateUIView(_ view: T, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
