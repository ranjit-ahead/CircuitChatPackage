//public struct CircuitChatPackage {
//    public private(set) var text = "Hello, World!"
//
//    public init() {
//    }
//}

import SwiftUI
import Alamofire

public struct CircuitChatPackage: App {
    
    public init() {}  // Add a public initializer
    
    public var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
