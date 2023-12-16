//
//  StarredMessage+Observed.swift
//  Chat
//
//  Created by Apple on 03/11/23.
//

import Foundation

extension StarredMessage {
    class Observed: ObservableObject {
        @Published var userChatDataArray: [UserChatData]?
        
        func starredMessage(_ chat: [UserChatData]) {
            var idArray:[String] = []
            for data in chat {
                if let id = data.id {
                    idArray.append(id)
                }
            }
            let bodyData: [String:Any] = [
                "message" : idArray
            ]
            circuitChatRequest("/message/unstarred", method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success:
                    for data in chat {
                        if let index = self.userChatDataArray?.firstIndex(of: data) {
                            self.userChatDataArray?.remove(at: index)
                        }
                    }
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func fetchChatMessages(id: String, type: String, password: String? = nil) {
            
            var url = "/message/starred/\(id)/\(type)"
            if id == circuitChatUID {
                url = "/message/allstared"
            }
            
            circuitChatRequest(url, method: .get, model: [UserChatData].self) { result in
                
                switch result {
                case .success(let data):
                    if data.count>0 {
                        self.userChatDataArray = data
                    }
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
    }
}
