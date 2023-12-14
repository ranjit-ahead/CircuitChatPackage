import SwiftUI

public struct CircuitChatPackage {
    public private(set) var text = "Hello, World!"
    
    public init() {
    }
    
    public func createMainTabView() -> some View {
        return MainTabView()
    }
}
