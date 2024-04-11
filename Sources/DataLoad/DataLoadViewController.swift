import Foundation
import UIKit
import ComposableArchitecture
import Utils

public final class DataLoadViewController: UIViewController {
    private let store: StoreOf<DataLoad>

    public init(store: StoreOf<DataLoad>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Views:
    private let activityIndicatorView: UIActivityIndicatorView = .withConfiguration {
        $0.style = .medium
        $0.hidesWhenStopped = true
    }

    private let informationLabel: UILabel = .withConfiguration {
        $0.textAlignment = .center
    }

    // MARK: - View Lifecycle:
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutViews()
        self.bindUI()
        self.store.send(.view(.task))
    }

    // MARK: - Private Funcs:
    private func bindUI() {
        self.view.backgroundColor = .systemBackground
        observe { [weak self] in
            guard let self
            else { return }
            
            if self.store.isLoadingData {
                self.activityIndicatorView.startAnimating()
            } else {
                self.activityIndicatorView.stopAnimating()
            }
            
            self.informationLabel.isHidden = self.store.isLoadingData
            if let errorMessage = self.store.errorMessage {
                self.informationLabel.text = "Error: \(errorMessage)"
            } else {
                self.informationLabel.text = "Accounts data loaded."
            }
        }
    }

    private func layoutViews() {
        self.view.addSubview(self.activityIndicatorView) { make in
            make.width.height.equalTo(30)
            make.center.equalTo(self.view)
        }
        self.view.addSubview(self.informationLabel) { make in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
