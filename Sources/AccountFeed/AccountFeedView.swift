import Foundation
import ComposableArchitecture
import SwiftUI
import Models
import APIClient

@ViewAction(for: AccountFeed.self)
public struct AccountFeedView: View {
    @Bindable public var store: StoreOf<AccountFeed>
    
    public init(store: StoreOf<AccountFeed>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            HStack {
                Button {
                    send(.prevWeekTapped)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(store.isLoading || store.isRoundingUp)
                .frame(width: 30, height: 30)

                if (store.isLoading) {
                    ProgressView()
                } else {
                    Text(store.interval?.formated() ?? "N/A")
                        .font(.headline)
                }
                Spacer()
                Button {
                    send(.nextWeekTapped)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(store.isLoading || store.isRoundingUp)
                .frame(width: 30, height: 30)
            }
            .frame(maxWidth: .infinity, minHeight: 30)
            .padding(.horizontal, 8)
            .padding(.top, 16)
            
            List {
                if store.feedItems.isEmpty {
                    Text("No transactions occured during this period.")
                        .italic()
                        .font(.caption)
                } else {
                    ForEach(store.feedItems) { item in
                        AccountFeedItemView(item: item)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("\(store.account.name)")
        .toolbar {
            if !store.feedItems.isEmpty {
                ToolbarItem {
                    if store.isRoundingUp {
                        ProgressView()
                    } else {
                        Button {
                            send(.roundUpTapped)
                        } label: {
                            Text("Round Up!")
                        }
                        .disabled(store.isLoading)
                    }
                }
            }
        }
        .task {
            await send(.task).finish()
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

extension AccountFeedView {
    struct AccountFeedItemView: View {
        let item: AccountFeedItem
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: self.item.direction.icon)
                    .frame(width: 24, height: 24)
                VStack(alignment: .leading) {
                    Text(self.item.title)
                        .bold()
                        .font(.headline)
                    if !self.item.subtitle.isEmpty {
                        Text(self.item.subtitle)
                            .font(.footnote)
                    }
                }
                Spacer()
                Divider()
                Text(self.item.source?.description ?? "N/A")
                    .font(.caption)
                    .frame(width: 40)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountFeedView(
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
    }
    .navigationBarTitleDisplayMode(.inline)
}

#Preview("empty list") {
    NavigationStack {
        AccountFeedView(
            store: .init(
                initialState: .init(
                    account: Account.init(
                        accountID: UUID(uuidString: "04a4f5ae-3962-4963-8e7f-da5b70ceb6fc")!,
                        accountType: .primary,
                        defaultCategory: "defaultCategory",
                        createdAt: Date(),
                        name: "Account Name"
                    )
                ),
                reducer: AccountFeed.init
            ) {
                $0[APIClient.self].overrideAnyGetAccountFeed(
                    response: [],
                    throwing: nil
                )
            }
        )
    }
    .navigationBarTitleDisplayMode(.inline)
}
