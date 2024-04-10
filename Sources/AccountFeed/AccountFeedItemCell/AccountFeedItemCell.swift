import Foundation
import UIKit
import Models
import SnapKit
import Utils
import SwiftUI

@MainActor
final class AccountFeedItemCell: UITableViewCell, IdentifiedCell {
    private let containerHStack: UIStackView = .init()
    private let directionIconView: UIImageView = .init()
    private let titleLabel: UILabel = .init()
    private let subtitleLabel: UILabel = .init()
    private let transactionTypeLabel: UILabel = .init()
    
    var viewModel: AccountFeedItem! {
        didSet {
            self.configureUI()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: Self.identifier)
        self.setupViews()
    }
    
    private func configureUI() {
        self.directionIconView.image = UIImage(systemName: self.viewModel.direction.icon)
        self.titleLabel.text = self.viewModel.title
        self.subtitleLabel.text = self.viewModel.subtitle
        self.subtitleLabel.isHidden = self.viewModel.subtitle.isEmpty
        self.transactionTypeLabel.text = self.viewModel.source?.description ?? "N/A"
    }
    
    private func setupViews() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.setupStackView()
        self.setupDirectionIconView()
        self.setupTitleAndSubtitleLabel()
        self.containerHStack.addArrangedSubview(UIView()) // Spacer
        self.setupSeparator()
        self.setupTransactionTypeLabel()
    }
    
    private func setupStackView() {
        self.containerHStack.axis = .horizontal
        self.containerHStack.alignment = .center
        self.containerHStack.spacing = 12
        self.containerHStack.layer.cornerRadius = 8
        self.containerHStack.backgroundColor = .systemFill
        self.containerHStack.clipsToBounds = true
        self.containerHStack.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        self.containerHStack.isLayoutMarginsRelativeArrangement = true
        
        self.addSubview(self.containerHStack)
        self.containerHStack.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }

    private func setupDirectionIconView() {
        self.directionIconView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
        }
        self.directionIconView.tintColor = .label
        self.containerHStack.addArrangedSubview(self.directionIconView)
    }
    
    private func setupTransactionTypeLabel() {
        self.transactionTypeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        self.transactionTypeLabel.numberOfLines = 2
        self.transactionTypeLabel.textAlignment = .center
        self.transactionTypeLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        self.containerHStack.addArrangedSubview(self.transactionTypeLabel)
    }
    
    private func setupSeparator() {
        let separator = UIView()
        separator.backgroundColor = .systemGray
        self.containerHStack.addArrangedSubview(separator)
        separator.snp.makeConstraints { make in
            make.width.equalTo(0.5)
            make.height.equalTo(self.containerHStack).multipliedBy(0.6)
        }
    }
    
    private func setupTitleAndSubtitleLabel() {
        let container = UIStackView()
        container.axis = .vertical
        self.titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        container.addArrangedSubview(self.titleLabel)
        self.subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        container.addArrangedSubview(self.subtitleLabel)
        self.containerHStack.addArrangedSubview(container)
    }
}

#Preview {
    let cell = AccountFeedItemCell(style: .default, reuseIdentifier: nil)
    cell.viewModel = .init(
        id: UUID(),
        direction: .inbound,
        reference: "Reference",
        amount: .init(currency: "GBP", minorUnits: 436),
        source: .fasterPaymentsOut,
        transactionTime: nil
    )
    return cell
}
