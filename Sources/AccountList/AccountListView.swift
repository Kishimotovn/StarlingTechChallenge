import Foundation
import ComposableArchitecture
import SwiftUI
import APIClient
import AccountFeed

public struct AccountListView: View {
    @Bindable
    public var store: StoreOf<AccountList>
    
    public init(store: StoreOf<AccountList>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            List {
                ForEach(
                    store.accounts,
                    content: { account in
                        NavigationLink(
                            state: AccountFeed.State(accountID: account.id)
                        ) {
                            AccountListItem(account: account)
                        }
                    }
                )
                .scrollContentBackground(.hidden)
                .listRowSeparator(.hidden)
            }
            .navigationTitle("Your Accounts")
            .frame(maxWidth: .greatestFiniteMagnitude)
        } destination: { store in
            AccountFeedView(store: store)
        }
    }
}

extension AccountListView {
    struct AccountListItem: View {
        let account: Account
        
        var body: some View {
            HStack(alignment: .center) {
                Text("\(account.currency)")
                    .bold()
                    .font(.callout)
                
                Divider()
                    .padding(.all, 4)

                VStack(alignment: .leading) {
                    Text(account.name)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.primary)
                    Text(account.accountType.rawValue)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview {
    AccountListView(
        store: .init(
            initialState: AccountList.State(
                accounts: [
                    .init(
                        accountID: "accountID1",
                        accountType: .primary,
                        defaultCategory: "defaultCategory",
                        createdAt: Date(),
                        name: "Phan Anh Tran"
                    ),
                    .init(
                        accountID: "accountID2",
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
}
