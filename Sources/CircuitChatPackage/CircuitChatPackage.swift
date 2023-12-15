import SwiftUI

public struct CircuitChatPackage {
    
    @ObservedObject private var socketIO: CircuitChatSocketManager = CircuitChatSocketManager()
    
    @ObservedObject private var observed = MainTabViewObserved()
    
    @State private var originalNavBarAppearance: UINavigationBarAppearance?
    
    public init(domain: String, userId: String, clientId: String, clientSecret: String) {
        circuitChatDomain = domain
        circuitChatUID = userId
        circuitChatClientID = clientId
        circuitChatClientSecret = clientSecret
    }

    // Function to create the main tab view
    public func createMainTabView() -> some View {
        return MainTabView(observed: observed)
            .environmentObject(socketIO)
            .onAppear {
                // Save the original appearance when the view appears
                originalNavBarAppearance = UINavigationBar.appearance().standardAppearance
                
                // Change to the default appearance when the view appears
                let defaultAppearance = UINavigationBarAppearance()
                UINavigationBar.appearance().standardAppearance = defaultAppearance
                UINavigationBar.appearance().scrollEdgeAppearance = defaultAppearance
            }
            .onDisappear {
                // Save the original appearance when the view appears
                UINavigationBar.appearance().standardAppearance = originalNavBarAppearance!
                UINavigationBar.appearance().scrollEdgeAppearance = originalNavBarAppearance!
            }
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
