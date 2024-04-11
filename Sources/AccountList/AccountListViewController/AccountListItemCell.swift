import Foundation
import UIKit
import Models
import SnapKit
import Utils
import SwiftUI

@MainActor
final class AccountListItemCell: UITableViewCell, IdentifiedCell {
    // MARK: - Views:
    private let containerHStack: UIStackView = .withConfiguration {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 12
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemFill
        $0.clipsToBounds = true
        $0.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    private let titleLabel: UILabel = .withConfiguration {
        $0.font = UIFont.preferredFont(forTextStyle: .headline)
    }
    private let subtitleLabel: UILabel = .withConfiguration {
        $0.font = UIFont.preferredFont(forTextStyle: .caption1)
    }
    private let currencyLabel: UILabel = .withConfiguration {
        $0.font = UIFont.preferredFont(forTextStyle: .callout)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    private let textVStack: UIStackView = .withConfiguration {
        $0.axis = .vertical
        $0.spacing = 2
    }
    private let separatorView: UIView = .withConfiguration {
        $0.backgroundColor = .systemGray6
    }
    private let disclosureIndicatorView: UIImageView = .withConfiguration {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .systemGray
        $0.contentMode = .scaleAspectFit
        $0.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
    }

    // MARK: - View Model:
    var account: Account! {
        didSet {
            self.bindUI()
        }
    }

    // MARK: - View Lifecycle:
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.containerHStack.backgroundColor = .tertiarySystemFill
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.containerHStack.backgroundColor = .systemFill
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.containerHStack.backgroundColor = .systemFill
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: Self.identifier)
        self.layoutViews()
    }

    // MARK: Private:
    private func bindUI() {
        self.titleLabel.text = self.account.name
        self.subtitleLabel.text = self.account.accountType.description
        self.currencyLabel.text = self.account.currency
    }

    private func layoutViews() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        // Text Stack
        self.textVStack.addArrangedSubview(self.titleLabel)
        self.textVStack.addArrangedSubview(self.subtitleLabel)
        
        // Container Stack
        self.containerHStack.addArrangedSubview(self.currencyLabel)
        self.containerHStack.addArrangedSubview(self.separatorView) { make in
            make.width.equalTo(0.5)
            make.height.equalTo(self.containerHStack).multipliedBy(0.6)
        }
        self.containerHStack.addArrangedSubview(self.textVStack)
        self.containerHStack.addArrangedSubview(self.disclosureIndicatorView)
        
        // View
        self.addSubview(self.containerHStack) { make in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    let cell = AccountListItemCell(style: .default, reuseIdentifier: nil)
    cell.account = .init(accountID: UUID(), accountType: .primary, defaultCategory: "cateogry", createdAt: Date(), name: "Personal")
    return cell
}
