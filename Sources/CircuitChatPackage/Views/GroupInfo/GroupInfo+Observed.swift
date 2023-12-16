//
//  GroupInfo+Observed.swift
//  Chat
//
//  Created by Apple on 30/10/23.
//

import Foundation

class GroupInfoObserved: ObservableObject {
    
    var toastMessage: String?
    
    var data: GroupInfoData?
    
    //MARK: EDIT GROUP
    func editGroup(_ id: String, groupName: String, metadata: String) {
        let bodyData: [String: Any] = [
            "group": id,
            "name": groupName,
            "metadata": metadata
        ]
        circuitChatRequest("/group/edit", method: .post, bodyData: bodyData, model: GroupInfoModel.self) { result in
            switch result {
            case .success(let data):
                self.data?.metadata = data.data.metadata
                self.toastMessage = data.message
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        }
    }
    
    //MUTE GROUP
    func muteChatNotifications(chat: LastChatData, time: Int? = nil) {
        var bodyData: [String:Any] = [
            "chat" : [ chat.id ]
        ]
        
        var url = "/chat/mute"
        if chat.mute ?? false {
            url = "/chat/unmute"
        } else {
            bodyData.updateValue(time ?? 1, forKey: "time")
        }
        circuitChatRequest(url, method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
            switch result {
            case .success(let data):
                self.toastMessage = data.message
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: DELETE CHAT
    func deleteChat(_ id: String) {
        let bodyData: [[String: Any]] = [[
            "chat": id,
            "chatType": "group"
        ]]
        circuitChatRequest("/chat/delete-conversation", method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
            switch result {
            case .success(let data):
                self.toastMessage = data.message
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: EXIT GROUP
    func exitGroup(_ id: String) {
        let bodyData: [String: Any] = [
            "group": id
        ]
        circuitChatRequest("/group/leave", method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
            switch result {
            case .success(let data):
                self.toastMessage = data.message
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: REPORT GROUP
    func reportGroup(_ id: String, leave: Bool = false) {
        let bodyData: [String: Any] = [
            "reportType": 3,
            "leave": leave,
            "report": id,
            "block": false,
            "message": "Report"
        ]
        circuitChatRequest("/user/report", method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
            switch result {
            case .success(let data):
                self.toastMessage = data.message
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: DELETE GROUP
    func deleteGroup(_ id: String) {
        let bodyData: [String: Any] = [
            "group": id
        ]
        circuitChatRequest("/group/delete", method: .delete, bodyData: bodyData, model: SuccessMessage.self) { result in
            switch result {
            case .success(let data):
                self.toastMessage = data.message
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: FETCH GROUP INFO
    func fetchInfo(_ id: String) {
        circuitChatRequest("/group/profile/\(id)", method: .get, model: GroupInfoModel.self) { result in
            switch result {
            case .success(let data):
                self.data = data.data
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        }
    }
}
