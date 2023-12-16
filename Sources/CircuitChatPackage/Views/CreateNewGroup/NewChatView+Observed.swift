//
//  NewChatView+Observed.swift
//  Chat
//
//  Created by Apple on 18/09/23.
//

import Foundation


extension NewChatView {
    class Observed: ObservableObject {
        
        var apiResponse: NewChatResponse?
        
        var frequentlyContactedArray: [Chat]?
        var chatArray: [NewChatContactsData]?
        
//        var chatMapping: [String: [Chat]]?
        
        var socketIO: CircuitChatSocketManager?
        
        func fetchApiData(apiRequest: ApiRequest) {
            circuitChatRequest(apiRequest.apiURL, method: apiRequest.apiMethod, model: NewChatResponse.self) { result in
                switch result {
                case .success(let data):
                    self.apiResponse = data
                    self.frequentlyContactedArray = data.menu.frequentlyContacted?.results
                    self.chatArray = data.menu.contacts?.requiredArray
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
    }
}
