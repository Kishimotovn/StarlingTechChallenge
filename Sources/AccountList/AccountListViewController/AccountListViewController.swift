import Foundation
import UIKit
import ComposableArchitecture
import AccountFeed
import Models

public final class AccountListViewController: UIViewController {
    private let store: StoreOf<AccountList>
    
    public init(store: StoreOf<AccountList>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Views
    private lazy var accountListTableView: UITableView = .withConfiguration {
        $0.register(AccountListItemCell.self, forCellReuseIdentifier: AccountListItemCell.identifier)
        $0.separatorStyle = .none
        $0.dataSource = self
        $0.backgroundColor = .systemBackground
        $0.delegate = self
        $0.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
    }

    // MARK: - View Lifecycle:
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.bindUI()
    }
    
    // MARK: - Private:
    private var accounts: [Account] = []
    private func bindUI() {
        observe { [weak self] in
            guard let self else { return }
            self.accounts = self.store.accounts.elements
            self.accountListTableView.reloadData()
        }
    }

    // MARK: - Layout Views:
    private func setupViews() {
        self.title = "Your Accounts"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.setupAccountListTableView()
    }
    
    private func setupAccountListTableView() {
        self.view.addSubview(self.accountListTableView) { make in
            make.edges.equalTo(self.view)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableView Datasource
extension AccountListViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountListItemCell.identifier, for: indexPath) as! AccountListItemCell
        if let account = self.accounts.get(at: indexPath.row) {
            cell.account = account
        }
        return cell
    }
}

// MARK: - UITableView Delegate
extension AccountListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard 
            let id = self.store.acountFeedPaths.get(at: indexPath.row)?.id,
            let store = self.store.scope(state: \.acountFeedPaths[id:id], action: \.acountFeedPaths[id:id])
        else {
            return
        }
        self.navigationController?.pushViewController(AccountFeedViewController(store: store), animated: true)
    }
}

#Preview {
    UINavigationController(
        rootViewController: AccountListViewController(
            store: .init(
                initialState: AccountList.State(
                    accounts: [
                        .init(
                            accountID: UUID(),
                            accountType: .primary,
                            defaultCategory: "defaultCategory",
                            createdAt: Date(),
                            name: "Phan Anh Tran"
                        ),
                        .init(
                            accountID: UUID(),
                            accountType: .additional,
                            defaultCategory: "defaultCategory",
                            createdAt: Date(),
                            name: "Phuong Nhung Nguyen"
                        )
                    ]
                ),
                reducer: AccountList.init
            )
        )
    )
}
