//
//  UserInfo+Observed.swift
//  Chat
//
//  Created by Apple on 31/10/23.
//

import Foundation

extension UserInfo {
    class Observed: ObservableObject {
        
        @Published var data: UserInfoData?
        
        //MARK: DELETE CHAT
        func deleteChat(_ id: String) {
            let bodyData: [String: Any] = [
                "chat": id,
                "chatType": "user"
            ]
            circuitChatRequest("/chat/delete-conversation", method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success(_):
                    print("success")
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        //MARK: BLOCK USER
        func blockUser(_ id: String) {
            let bodyData: [String: Any] = [
                "user": id
            ]
            circuitChatRequest("/friend/block", method: .delete, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success(_):
                    print("success")
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        //MARK: REPORT USER
        func reportUser(_ id: String) {
            let bodyData: [String: Any] = [
                "groupId": id
            ]
            circuitChatRequest("/user/report", method: .delete, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success(_):
                    print("success")
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func fetchInfo(_ id: String) {
            circuitChatRequest("/user/profile/\(id)", method: .get, model: UserInfoModel.self) { result in
                switch result {
                case .success(let data):
                    self.data = data.data
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
    }
}
