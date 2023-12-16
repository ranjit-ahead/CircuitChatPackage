//
//  AddMembersModel.swift
//  Chat
//
//  Created by Apple on 01/12/23.
//

import Foundation

extension AddMembersView {
    class Observed: ObservableObject {
        
        var apiResponse: NewChatResponse?
        
        var frequentlyContactedArray: [Chat]?
        var chatArray: [NewChatContactsData]?
        
        var socketIO: CircuitChatSocketManager?
        
        func sendMessage(apiRequest: ApiRequest, messages: [String], users: [String]) {
            let bodyData: [String: Any] = [
                "messageId": messages,
                "users": users
            ]
            circuitChatRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: NewChatResponse.self) { result in
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
