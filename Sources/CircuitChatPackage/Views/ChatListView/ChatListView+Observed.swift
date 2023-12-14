//
//  ContentViewModel.swift
//  Chat
//
//  Created by Apple on 22/08/23.
//

import Foundation
import SwiftUI

//extension ChatListView {
    class ChatListViewObserved: ObservableObject {
        
        @Published var apiResponse: LastChatResponse?
        @Published var apiRequest: ApiRequest?
        
        @Published var moreMenus: LastChatMoreMenu?
        
        @Published var pageCount = 1
        @Published var limitCount = 15
        
        @Published var archived = false
        @Published var archivedResponse: LastChatResponse?
        
        @Published var activeUserResponse: ActiveFriends?
        
        func reportChat(chat: LastChatData, apiRequest: ApiRequest, block: Bool, leave: Bool) {
            let bodyData: [String:Any] = [
                "reportType" : chat.chat.chatType=="group" ? 3 : 2,
                "report" : chat.chat.id,
                "block" : block,
                "leave" : leave
            ]
            circuitChatRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success:
                    print("\(chat.chat.id)")
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func blockChat(chat: LastChatData, apiRequest: ApiRequest) {
            let bodyData: [String:Any] = [
                "user" : chat.chat.id
            ]
            circuitChatRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success:
                    print("\(chat.chat.id)")
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func readDeleteChatNotification(chats: [LastChatData], apiRequest: ApiRequest) {
            var bodyData: [[String:Any]] = []
            for chat in chats {
                bodyData.append([
                    "chat" : chat.chat.id,
                    "chatType" : chat.chat.chatType ?? "user"
                ])
            }
            circuitChatRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success:
                    print(bodyData)
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func muteChatNotifications(apiRequest: ApiRequest, chat: LastChatData, time: Int? = nil) {
            var bodyData: [String:Any] = [
                "chat" : [ chat.chat.id ]
            ]
            bodyData.updateValue(time ?? 1, forKey: "time")
            circuitChatRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success(_):
                    print("\(chat.chat.id)")
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
         
        func pinChat(chat: LastChatData) {
            let bodyData: [String:Any] = [
                "chat" : [ chat.id ]
            ]
            var url = "/chat/pin"
            if chat.pin ?? false {
                url = "/chat/unpin"
            }
            circuitChatRequest(url, method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success:
                    if let data = self.apiResponse?.menu.chats {
//                        for index in 0..<data.count {
//                            if data[index].id == chat.id  {
//                                self.apiResponse?.menu.chats[index].pin = (chat.pin ?? false) ? false : true
//                                if !(chat.pin ?? false) {
//                                    if let chatData = self.apiResponse?.menu.chats.remove(at: index) {
//                                        self.apiResponse?.menu.chats.insert(chatData, at: 0)
//                                    }
//                                }
//                            }
//                        }
                    }
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func archiveChat(chatIds: [String]) {
            let bodyData: [String:Any] = [
                "chat" : chatIds
            ]
            var url = "/chat/archive"
            if archived {
                url = "/chat/unarchive"
            }
            circuitChatRequest(url, method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success(let data):
                    print(data)
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func deleteConversation(chatIds: [ChatIDAndType], apiRequest: ApiRequest) {
            var bodyData: [[String: Any]] = [[:]]
            for chatIDAndType in chatIds {
                bodyData.append(["chat": chatIDAndType.id, "chatType": chatIDAndType.chatType])
            }
            bodyData.removeFirst()
            circuitChatRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success(_):
                    print("success")
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func fetchOnlineMembers() {
            circuitChatRequest("/friend/active", method: .get, model: ActiveFriends.self) { result in
                switch result {
                case .success(let data):
                    self.activeUserResponse = data
                    self.activeUserResponse?.data.enumerated().forEach { index, user in
                        self.activeUserResponse?.data[index].active = true
                    }
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func hasReachedEnd(of lastChatData: LastChatData, array: [LastChatData]) -> Bool {
            return array.last == lastChatData
        }
        
        func fetchChatMenus(chat: LastChatData, apiRequest: ApiRequest) {
            circuitChatRequest("/chat/more/\(chat.chat.chatType ?? "")/\(chat.chat.id)/\(chat.unread)", method: apiRequest.apiMethod, model: LastChatMoreMenu.self) { result in
                switch result {
                case .success(let data):
                    self.moreMenus = data
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func fetchApiData(apiRequest: ApiRequest?) {
            if let apiRequest = apiRequest {
                var url = "\(apiRequest.apiURL)?page=\(pageCount)&limit=\(limitCount)"
                if archived {
                    url += "&archive=\(archived)"
                }
                circuitChatRequest(url, method: apiRequest.apiMethod, model: LastChatResponse.self) { result in
                    switch result {
                    case .success(let data):
                        if self.apiResponse == nil {
                            self.apiResponse = data
                        } else {
                            self.apiResponse?.menu.chats.append(contentsOf: data.menu.chats)
                        }
//                        if data.menu.chats.count > 0 {
                            self.pageCount += 1
//                        }
                    case .failure(let error):
                        print("Error fetching chat messages: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        func fetchSingleChat(chatId: String) {
            circuitChatRequest("/api/chat?chatId=\(chatId)", method: .get, model: LastChatResponse.self) { result in
                switch result {
                case .success(let data):
                    if self.apiResponse == nil {
                        self.apiResponse = data
                    } else {
                        self.apiResponse?.menu.chats.append(contentsOf: data.menu.chats)
                    }
                    if data.menu.chats.count > 0 {
                        self.pageCount += 1
                    }
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func getIndexOfChat(_ chatId: String) -> Int {
            guard let chats = self.apiResponse?.menu.chats else {
                return 0
            }
            
            // Sort the chats by createdAt date
            let sortedChats = chats.sorted { (chat1, chat2) -> Bool in
                // If chat1 has pin set to true and chat2 doesn't, prioritize chat1
                if chat1.pin == true && chat2.pin == false {
                    return true
                }
                // If chat1 has pin set to false and chat2 has pin set to true, prioritize chat2
                else if chat1.pin == false && chat2.pin == true {
                    return false
                }
                // Otherwise, compare based on the createdAt date
                else {
                    guard let date1 = chat1.userChatData?.createdAt, let date2 = chat2.userChatData?.createdAt else {
                        return false
                    }
                    return date1 > date2
                }
            }
            
            // Create a dictionary to store the index for each chatId
            var indexByChatId: [String: Int] = [:]
            for (index, chat) in sortedChats.enumerated() {
                indexByChatId[chat.chat.id] = index
            }
            
            // Find the index of the chat with the specified chatId
            if let chatIndex = indexByChatId[chatId] {
                return chatIndex
            }
            return 0
        }
        
        
        func getIndexOfChatFromChat(_ chat: LastChatData) -> Int {
            guard var chats = self.apiResponse?.menu.chats else {
                return 0
            }
            
            if !chats.contains(where: { $0.id == chat.id }) {
                chats.append(chat)
            }
            
            // Sort the chats by createdAt date
            chats = chats.sorted { (chat1, chat2) -> Bool in
                // If chat1 has pin set to true and chat2 doesn't, prioritize chat1
                if chat1.pin == true && chat2.pin == false {
                    return true
                }
                // If chat1 has pin set to false and chat2 has pin set to true, prioritize chat2
                else if chat1.pin == false && chat2.pin == true {
                    return false
                }
                // Otherwise, compare based on the createdAt date
                else {
                    guard let date1 = chat1.userChatData?.createdAt, let date2 = chat2.userChatData?.createdAt else {
                        return false
                    }
                    return date1 > date2
                }
            }
            
            // Create a dictionary to store the index for each chatId
            var indexByChatId: [String: Int] = [:]
            for (index, chat) in chats.enumerated() {
                indexByChatId[chat.chat.id] = index
            }
            
            // Find the index of the chat with the specified chatId
            if let chatIndex = indexByChatId[chat.id] {
                return chatIndex
            }
            return 0
        }
    }
//}
