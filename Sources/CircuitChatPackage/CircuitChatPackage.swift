import SwiftUI

public struct CircuitChatPackage {
    
    public init() {
    }
    
    public func createMainTabView() -> some View {
        return MainTabView()
    }
    
    public func login(domain: String, userId: String, clientId: String, clientSecret: String) {
        circuitChatDomain = domain
        circuitChatUID = userId
        circuitChatClientID = clientId
        circuitChatClientSecret = clientSecret
    }
    
    public func logout() {
        
    }
}
