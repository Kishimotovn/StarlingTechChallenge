import Foundation
import UIKit
import DataLoad
import AccountList
import ComposableArchitecture

public final class AppRootViewController: UIViewController {
    private let store: StoreOf<AppRoot>
    private var currentViewController = UIViewController() {
        willSet {
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
            addChild(newValue)
            view.addSubview(newValue.view)
            newValue.didMove(toParent: self)
        }
    }

    public init(store: StoreOf<AppRoot>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        observe { [weak self] in
            guard let self else { return }
            
            switch self.store.mode {
            case .dataLoad:
                guard self.currentViewController as? DataLoadViewController == nil else { return }
                if let store = store.scope(state: \.mode.dataLoad, action: \.mode.dataLoad) {
                    self.currentViewController = DataLoadViewController(store: store)
                }
            case .accountList:
                guard self.currentViewController as? AccountListViewController == nil else { return }
                if let store = store.scope(state: \.mode.accountList, action: \.mode.accountList) {
                    self.currentViewController = UINavigationController(rootViewController: AccountListViewController(store: store))
                }
            }
        }
    }
}
