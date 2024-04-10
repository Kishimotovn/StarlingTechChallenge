import Foundation
import UIKit
import ComposableArchitecture
import SnapKit
import AccountFeed
import Models

public class AccountListViewController: UIViewController {
    private let store: StoreOf<AccountList>
    private let accountListTableView: UITableView = .init()
    private var accounts: [Account] = []
    
    public init(store: StoreOf<AccountList>) {
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
            self.accounts = self.store.accounts.elements
            self.accountListTableView.reloadData()
        }
    }
    
    private func setupViews() {
        self.title = "Your Accounts"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.setupAccountListTableView()
    }
    
    private func setupAccountListTableView() {
        self.accountListTableView.register(AccountListItemCell.self, forCellReuseIdentifier: AccountListItemCell.identifier)
        self.accountListTableView.separatorStyle = .none
        self.accountListTableView.dataSource = self
        self.accountListTableView.backgroundColor = .systemBackground
        self.accountListTableView.delegate = self
        self.view.addSubview(self.accountListTableView)
        self.accountListTableView.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
        self.accountListTableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
}

extension AccountListViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountListItemCell.identifier, for: indexPath) as! AccountListItemCell
        if let item = self.accounts.get(at: indexPath.row) {
            cell.viewModel = .init(title: item.name, subtitle: item.accountType.description, currency: item.currency)
        }
        return cell
    }
}

extension AccountListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = store.acountFeedPaths[indexPath.row].id
        if let store = store.scope(state: \.acountFeedPaths[id:id], action: \.acountFeedPaths[id:id]) {
            navigationController?.pushViewController(AccountFeedViewController(store: store), animated: true)
        }
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
