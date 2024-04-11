import Foundation
import UIKit
import SnapKit

public extension UIView {
    static func withConfiguration<T: UIView>(_ apply: (T) -> Void) -> T {
        let view = T.init()
        apply(view)
        return view
    }

    func addSubview(_ view: UIView, makingConstraints: (ConstraintMaker) -> Void) {
        self.addSubview(view)
        view.snp.makeConstraints(makingConstraints)
    }
}

public extension UIStackView {
    func addArrangedSubview(_ view: UIView, makingConstraints: (ConstraintMaker) -> Void) {
        self.addArrangedSubview(view)
        view.snp.makeConstraints(makingConstraints)
    }
}
