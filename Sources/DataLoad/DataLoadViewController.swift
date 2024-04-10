import Foundation
import UIKit
import ComposableArchitecture
import SnapKit

public class DataLoadViewController: UIViewController {
    private let store: StoreOf<DataLoad>

    private let activityIndicatorView: UIActivityIndicatorView = .init(style: .medium)
    private let informationLabel: UILabel = .init()

    public init(store: StoreOf<DataLoad>) {
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

        self.store.send(.view(.task))
    }

    private func setupViews() {
        self.setupActivityIndicator()
        self.setupInformationLabel()
    }

    private func setupActivityIndicator() {
        self.activityIndicatorView.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.center.equalTo(self.view)
        }
    }

    private func setupInformationLabel() {
        self.informationLabel.textAlignment = .center
        self.view.addSubview(self.informationLabel)
        self.informationLabel.snp.makeConstraints { make in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        }
    }
}
