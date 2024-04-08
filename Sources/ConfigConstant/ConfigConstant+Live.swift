import Foundation

public extension ConfigConstant {
    static var live: Self {
        .init(
            getConfig: {
                do {
                    guard let path = Bundle.main.path(forResource: "ConfigConstant", ofType: "plist") else {
                        fatalError("No config file")
                    }
                    
                    let url = URL(filePath: path)
                    let data = try Data(contentsOf: url)
                    
                    return try PropertyListDecoder().decode(ConfigPlist.self, from: data)
                } catch {
                    fatalError("\(error)")
                }
            }
        )
    }
}

