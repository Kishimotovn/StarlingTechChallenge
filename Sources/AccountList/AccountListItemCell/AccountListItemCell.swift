import Foundation
import UIKit
import Models
import SnapKit
import Utils
import SwiftUI

class AccountListItemCell: UITableViewCell, IdentifiedCell {
    private let stackView: UIStackView = .init()
    private let titleLabel: UILabel = .init()
    private let subtitleLabel: UILabel = .init()
    private let currencyLabel: UILabel = .init()

    var viewModel: ViewModel! {
        didSet {
            self.configureUI()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.stackView.backgroundColor = .tertiarySystemFill
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.stackView.backgroundColor = .systemFill
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.stackView.backgroundColor = .systemFill
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: Self.identifier)
        self.setupViews()
    }

    private func configureUI() {
        self.titleLabel.text = self.viewModel.title
        self.subtitleLabel.text = self.viewModel.subtitle
        self.currencyLabel.text = self.viewModel.currency
    }

    private func setupViews() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.setupStackView()
        self.setupCurrencyLabel()
        self.setupSeparator()
        self.setupTitleAndSubtitleLabel()
        self.setupDisclosureIndicator()
    }
    
    private func setupStackView() {
        self.stackView.axis = .horizontal
        self.stackView.alignment = .center
        self.stackView.spacing = 12
        self.stackView.layer.cornerRadius = 8
        self.stackView.backgroundColor = .systemFill
        self.stackView.clipsToBounds = true
        self.stackView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        self.stackView.isLayoutMarginsRelativeArrangement = true
        
        self.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }

    private func setupCurrencyLabel() {
        self.currencyLabel.font = .boldSystemFont(ofSize: 16)
        self.currencyLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.currencyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.stackView.addArrangedSubview(self.currencyLabel)
    }

    private func setupSeparator() {
        let separator = UIView()
        separator.backgroundColor = .systemGray6
        stackView.addArrangedSubview(separator)
        separator.snp.makeConstraints { make in
            make.width.equalTo(0.5)
            make.height.equalTo(self.stackView).multipliedBy(0.6)
        }
    }

    private func setupTitleAndSubtitleLabel() {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 2
        self.titleLabel.font = .boldSystemFont(ofSize: 18)
        container.addArrangedSubview(self.titleLabel)
        self.subtitleLabel.font = .systemFont(ofSize: 12)
        container.addArrangedSubview(self.subtitleLabel)
        self.stackView.addArrangedSubview(container)
    }

    private func setupDisclosureIndicator() {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
        self.stackView.addArrangedSubview(imageView)
    }
}

extension AccountListItemCell {
    struct ViewModel {
        let title: String
        let subtitle: String
        let currency: String
    }
}

#Preview {
    let cell = AccountListItemCell(style: .default, reuseIdentifier: nil)
    cell.viewModel = .init(title: "Personal", subtitle: "Primary", currency: "GBP")
    return cell
}
