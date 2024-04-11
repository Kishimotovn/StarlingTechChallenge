import Foundation
import UIKit
import ComposableArchitecture
import SnapKit
import Models
import Utils

public final class AccountFeedViewController: UIViewController {
    private let store: StoreOf<AccountFeed>

    public init(store: StoreOf<AccountFeed>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Views:
    private lazy var accountFeedTableView: UITableView = .withConfiguration {
        $0.register(AccountFeedItemCell.self, forCellReuseIdentifier: AccountFeedItemCell.identifier)
        $0.separatorStyle = .none
        $0.dataSource = self
        $0.backgroundColor = .systemBackground
        $0.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
    }
    private let headerStack: UIStackView = .withConfiguration {
        $0.axis = .horizontal
        $0.spacing = 8
    }
    private lazy var nextWeekButton: UIButton = .withConfiguration {
        $0.setImage(.init(systemName: "chevron.right"), for: .normal)
        $0.addAction(.init { [weak self] _ in
            guard let self else { return }
            self.store.send(.view(.nextWeekTapped))
        }, for: .touchUpInside)
        $0.snp.makeConstraints { make in
            make.height.width.equalTo(30)
        }
    }
    private let weekIntervalLabel: UILabel = .withConfiguration {
        $0.font = .preferredFont(forTextStyle: .headline)
    }
    private let loadingIndicatorView: UIActivityIndicatorView = .withConfiguration {
        $0.style = .medium
        $0.hidesWhenStopped = true
    }
    private lazy var prevWeekButton: UIButton = .withConfiguration {
        $0.setImage(.init(systemName: "chevron.left"), for: .normal)
        $0.addAction(.init { [weak self] _ in
            guard let self else { return }
            self.store.send(.view(.prevWeekTapped))
        }, for: .touchUpInside)
        $0.snp.makeConstraints { make in
            make.height.width.equalTo(30)
        }
    }
    private lazy var roundUpBarButtonItem: UIBarButtonItem = {
        .init(title: "Round Up!", primaryAction: .init(title: "Round Up!", handler: { [weak self] _ in
            guard let self else { return }
            self.store.send(.view(.roundUpTapped))
        }))
    }()
    private var roundingUpIndicatorView: UIActivityIndicatorView = .init(style: .medium)
    private weak var alertController: UIAlertController?
    private lazy var emptyTableBackgroundView: UILabel = .withConfiguration {
        $0.text = "No transactions occured during this period."
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.textAlignment = .center
    }

    // MARK: - View Lifecyle:
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutViews()
        self.bindUI()
        self.store.send(.view(.task))
    }
    
    // MARK: - Privates:
    private var feedItems: [AccountFeedItem] = []
    private func bindUI() {
        observe { [weak self] in
            guard let self else { return }
            self.title = "\(self.store.account.name)"
            self.weekIntervalLabel.text = self.store.interval?.formated() ?? "N/A"
            self.weekIntervalLabel.isHidden = self.store.isLoading
            self.store.isLoading ? self.loadingIndicatorView.startAnimating() : self.loadingIndicatorView.stopAnimating()
            self.nextWeekButton.isEnabled = !self.store.isLoading && !self.store.isRoundingUp
            self.prevWeekButton.isEnabled = !self.store.isLoading && !self.store.isRoundingUp
            self.roundUpBarButtonItem.isEnabled = !store.isLoading
        }
        observe { [weak self] in
            guard let self else { return }
            if self.store.feedItems.isEmpty {
                self.navigationItem.rightBarButtonItem = nil
            } else {
                self.navigationItem.rightBarButtonItem = self.store.isRoundingUp ?  .init(customView: self.roundingUpIndicatorView) : self.roundUpBarButtonItem
                self.store.isRoundingUp ? self.roundingUpIndicatorView.startAnimating() : self.roundingUpIndicatorView.stopAnimating()
            }
        }
        observe {[weak self] in
            guard let self else { return }
            self.feedItems = self.store.feedItems.elements
            self.accountFeedTableView.reloadData()
        }
        observe { [weak self] in
            guard let self else { return }
            
            if let store = store.scope(state: \.alert, action: \.alert), self.alertController == nil{
                let alertController = UIAlertController(store: store)
                self.present(alertController, animated: true, completion: nil)
                self.alertController = alertController
            } else if store.alert == nil, self.alertController != nil {
                self.alertController?.dismiss(animated: true)
                self.alertController = nil
            }
        }
    }

    private func layoutViews() {
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.headerStack.addArrangedSubview(self.prevWeekButton)
        self.headerStack.addArrangedSubview(self.loadingIndicatorView)
        self.headerStack.addArrangedSubview(self.weekIntervalLabel)
        self.headerStack.addArrangedSubview(UIView()) // Spacer
        self.headerStack.addArrangedSubview(self.nextWeekButton)
        self.view.addSubview(self.headerStack) { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view).offset(16)
            make.right.equalTo(self.view).offset(-16)
        }
        self.view.addSubview(self.accountFeedTableView) { make in
            make.horizontalEdges.equalTo(self.view)
            make.top.equalTo(self.headerStack.snp.bottom).offset(16)
            make.bottom.equalTo(self.view)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDataSource:
extension AccountFeedViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.feedItems.isEmpty {
            tableView.backgroundView = self.emptyTableBackgroundView
        } else {
            tableView.backgroundView = nil
        }
        return self.feedItems.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountFeedItemCell.identifier, for: indexPath) as! AccountFeedItemCell
        if let item = self.feedItems.get(at: indexPath.row) {
            cell.feedItem = item
        }
        return cell
    }
}

#Preview {
    UINavigationController(
        rootViewController: AccountFeedViewController(
            store: .init(
                initialState: .init(
                    account: Account.init(
                        accountID: UUID(),
                        accountType: .primary,
                        defaultCategory: "defaultCategory",
                        createdAt: Date(),
                        name: "Account Name"
                    )
                ),
                reducer: AccountFeed.init
            )
        )
    )
}
