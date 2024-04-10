import Foundation
import UIKit
import ComposableArchitecture
import SnapKit
import Models

@MainActor
public final class AccountFeedViewController: UIViewController {
    private let store: StoreOf<AccountFeed>
    private let accountFeedTableView: UITableView = .init()
    private let headerStack: UIStackView = .init()
    private var nextWeekButton: UIButton!
    private let weekIntervalLabel: UILabel = .init()
    private let loadingIndicatorView: UIActivityIndicatorView = .init(style: .medium)
    private var prevWeekButton: UIButton!
    private var roundUpBarButtonItem: UIBarButtonItem!
    private var roundingUpIndicatorView: UIActivityIndicatorView = .init(style: .medium)
    private var feedItems: [AccountFeedItem] = []
    private weak var alertController: UIAlertController?
    private lazy var emptyTableBackgroundView: UIView = {
        let label = UILabel()
        label.text = "No transactions occured during this period."
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        return label
    }()
    
    @objc private func onNextWeekTapped(sender: UIButton) {
        self.store.send(.view(.nextWeekTapped))
    }
    
    @objc private func onPrevWeekTapped(sender: UIButton) {
        self.store.send(.view(.prevWeekTapped))
    }

    public init(store: StoreOf<AccountFeed>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
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
            self.navigationItem.rightBarButtonItem = self.store.isRoundingUp ?  .init(customView: self.roundingUpIndicatorView) : self.roundUpBarButtonItem
            self.store.isRoundingUp ? self.roundingUpIndicatorView.startAnimating() : self.roundingUpIndicatorView.stopAnimating()
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
        self.store.send(.view(.task))
    }
    
    private func setupViews() {
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.setupHeaderStack()
        self.setupAccountListTableView()
        self.setupRoundUpToolBarItem()
    }

    private func setupRoundUpToolBarItem() {
        self.roundUpBarButtonItem = .init(title: "Round Up!", primaryAction: .init(title: "Round Up!", handler: { [weak self] _ in
            guard let self else { return }
            self.store.send(.view(.roundUpTapped))
        }))
    }

    private func setupHeaderStack() {
        self.headerStack.axis = .horizontal
        self.headerStack.spacing = 8
        
        self.nextWeekButton = UIButton(
            type: .system,
            primaryAction: .init(
                image: .init(systemName: "chevron.right")
            ) { [weak self] _ in
                guard let self else { return }
                self.store.send(.view(.nextWeekTapped))
            }
        )
        self.nextWeekButton.snp.makeConstraints { make in
            make.height.width.equalTo(30)
        }
        self.weekIntervalLabel.font = .preferredFont(forTextStyle: .headline)
        self.loadingIndicatorView.hidesWhenStopped = true
        
        self.prevWeekButton = UIButton(
            type: .system,
            primaryAction: .init(
                image: .init(systemName: "chevron.left")
            ) { [weak self] _ in
                guard let self else { return }
                self.store.send(.view(.prevWeekTapped))
            }
        )
        self.prevWeekButton.snp.makeConstraints { make in
            make.height.width.equalTo(30)
        }

        self.headerStack.addArrangedSubview(self.prevWeekButton)
        self.headerStack.addArrangedSubview(self.loadingIndicatorView)
        self.headerStack.addArrangedSubview(self.weekIntervalLabel)
        self.headerStack.addArrangedSubview(UIView()) // Spacer
        self.headerStack.addArrangedSubview(self.nextWeekButton)
        self.view.addSubview(self.headerStack)
        self.headerStack.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view).offset(16)
            make.right.equalTo(self.view).offset(-16)
        }
    }

    private func setupAccountListTableView() {
        self.view.addSubview(self.accountFeedTableView)
        self.accountFeedTableView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.view)
            make.top.equalTo(self.headerStack.snp.bottom).offset(16)
            make.bottom.equalTo(self.view)
        }
        self.accountFeedTableView.register(AccountFeedItemCell.self, forCellReuseIdentifier: AccountFeedItemCell.identifier)
        self.accountFeedTableView.separatorStyle = .none
        self.accountFeedTableView.dataSource = self
        self.accountFeedTableView.backgroundColor = .systemBackground
        self.accountFeedTableView.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
    }
}

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
            cell.viewModel = item
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
