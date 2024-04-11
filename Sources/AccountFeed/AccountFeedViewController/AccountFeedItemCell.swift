import Foundation
import UIKit
import Models
import SnapKit
import Utils

@MainActor
final class AccountFeedItemCell: UITableViewCell, IdentifiedCell {
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
    private let directionIconView: UIImageView = .withConfiguration {
        $0.snp.makeConstraints { make in
            make.height.width.equalTo(24)
        }
        $0.tintColor = .label
    }
    private let separatorView: UIView = .withConfiguration {
        $0.backgroundColor = .systemGray
        $0.snp.makeConstraints { make in
            make.width.equalTo(0.5)
        }
    }
    private let titleLabel: UILabel = .withConfiguration {
        $0.font = .preferredFont(forTextStyle: .headline)
    }
    private let subtitleLabel: UILabel = .withConfiguration {
        $0.font = .preferredFont(forTextStyle: .footnote)
    }
    private let textVStack: UIStackView = .withConfiguration {
        $0.axis = .vertical
    }
    private let transactionTypeLabel: UILabel = .withConfiguration {
        $0.font = UIFont.preferredFont(forTextStyle: .caption1)
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
    }
    
    // MARK: - View Model:
    var feedItem: AccountFeedItem! {
        didSet {
            self.bindUI()
        }
    }
    
    // MARK: - View Lifecycle:
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: Self.identifier)
        self.layoutViews()
    }
    
    // MARK: - Private:
    private func bindUI() {
        self.directionIconView.image = UIImage(systemName: self.feedItem.direction.icon)
        self.titleLabel.text = self.feedItem.title
        self.subtitleLabel.text = self.feedItem.subtitle
        self.subtitleLabel.isHidden = self.feedItem.subtitle.isEmpty
        self.transactionTypeLabel.text = self.feedItem.source?.description ?? "N/A"
    }
    
    private func layoutViews() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        // Text VStack:
        self.textVStack.addArrangedSubview(self.titleLabel)
        self.textVStack.addArrangedSubview(self.subtitleLabel)
        
        // Container:
        self.containerHStack.addArrangedSubview(self.directionIconView)
        self.containerHStack.addArrangedSubview(self.textVStack)
        self.containerHStack.addArrangedSubview(UIView()) // Spacer
        self.containerHStack.addArrangedSubview(self.separatorView) { make in
            make.height.equalTo(self.containerHStack).multipliedBy(0.6)
        }
        self.containerHStack.addArrangedSubview(self.transactionTypeLabel)
        
        // Cell:
        self.addSubview(self.containerHStack) { make in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    let cell = AccountFeedItemCell(style: .default, reuseIdentifier: nil)
    cell.feedItem = .init(
        id: UUID(),
        direction: .inbound,
        reference: "Reference",
        amount: .init(currency: "GBP", minorUnits: 436),
        source: .fasterPaymentsOut,
        transactionTime: nil
    )
    return cell
}
