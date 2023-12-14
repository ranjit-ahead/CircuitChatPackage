import SwiftUI

public struct CircuitChatPackage {
    
    @ObservedObject private var socketIO: CircuitChatSocketManager = CircuitChatSocketManager()
    
    public init(domain: String, userId: String, clientId: String, clientSecret: String) {
        circuitChatDomain = domain
        circuitChatUID = userId
        circuitChatClientID = clientId
        circuitChatClientSecret = clientSecret
    }

    // Function to create the main tab view
    public func createMainTabView() -> some View {
        return MainTabView().environmentObject(socketIO)
    }

    // Function to handle login
    public func login() {
        // Implement your login logic here
        
        circuitChatRequest("/user/login-uid", method: .post, model: MainTabViewData.self) { result in
            switch result {
            case .success(let data):
                circuitChatToken = data.token
                self.apiResponse = data
                self.socketIO?.connectSocket()
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        }
    }

    // Function to handle logout
    public func logout() {
        // Implement your logout logic here
    }
}
