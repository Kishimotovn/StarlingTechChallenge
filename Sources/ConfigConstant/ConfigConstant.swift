import Foundation
import ComposableArchitecture

@DependencyClient
public struct ConfigConstant {
    var getConfig: @Sendable () -> ConfigPlist = { .init() }

    public var apiBaseURL: String { getConfig().apiBaseURL }
}

public struct ConfigPlist: Decodable {
    let apiBaseURL: String

    public init(
        apiBaseURL: String = ""
    ) {
        self.apiBaseURL = apiBaseURL
    }
}

extension ConfigConstant: DependencyKey {
    public static var testValue: ConfigConstant = .init()
    public static var previewValue: ConfigConstant = .init()
    public static var liveValue: ConfigConstant = .live
}
