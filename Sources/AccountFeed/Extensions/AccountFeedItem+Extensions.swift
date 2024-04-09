import Foundation
import Models

extension AccountFeedItem {
    static let transactionTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd MMM"
        return formatter
    }()

    var title: String {
        self.amount?.description ?? "N/A"
    }

    var subtitle: String {
        var infos = [String]()
        
        if let reference {
            infos.append(reference)
        }
        
//        if let transactionTime {
//            infos.append(AccountFeedItem.transactionTimeFormatter.string(from: transactionTime))
//        }
        
        return infos.joined(separator: " - ")
    }
}
