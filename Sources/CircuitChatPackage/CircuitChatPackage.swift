import SwiftUI

public struct CircuitChatPackage {
    
    @ObservedObject private var socketIO: CircuitChatSocketManager = CircuitChatSocketManager()
    
    @StateObject private var observed = MainTabViewObserved()
    
    public init(domain: String, userId: String, clientId: String, clientSecret: String) {
        circuitChatDomain = domain
        circuitChatUID = userId
        circuitChatClientID = clientId
        circuitChatClientSecret = clientSecret
    }

    // Function to create the main tab view
    public func createMainTabView() -> some View {
        return MainTabView()
            .environmentObject(socketIO)
    }

    // Function to handle login
    public func login() {
        // Implement your login logic here
        observed.fetchApiData()
    }

    // Function to handle logout
    public func logout() {
        // Implement your logout logic here
    }
}
