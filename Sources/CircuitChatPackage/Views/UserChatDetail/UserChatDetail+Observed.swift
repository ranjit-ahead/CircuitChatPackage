//
//  UserChatDetail+Observed.swift
//  Chat
//
//  Created by Apple on 13/09/23.
//

import Foundation
import UIKit

//extension UserChatDetail {
    class UserChatDetailObserved: ObservableObject {
        @Published var userChat: UserChat?
        
        @Published var toastMessage: String?
        
        @Published var userChatDataArray: [UserChatData]?
        @Published var userChatData: UserChatData?
        @Published var scrolledUserChatData: UserChatData?
        @Published var pageCount = 1
        @Published var limitCount = 10
        @Published var requestFetching = false
        
        func reportChat(apiRequest: ApiRequest, block: Bool, leave: Bool) {
            let bodyData: [String:Any] = [
                "reportType" : 1,
                "report" : self.userChatData?.id ?? "",
                "block" : block,
                "leave" : leave
            ]
            circuitChatRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success(let data):
                    self.toastMessage = data.message
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func unblockChat(apiRequest: ApiRequest, user: String) {
            let bodyData: [String:Any] = [
                "user" : user
            ]
            circuitChatRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success(let data):
                    self.toastMessage = data.message
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func deleteMessage(_ chat: [UserChatData], forEveryone: Bool = false) {
            var idArray:[String] = []
            for data in chat {
                if let id = data.id {
                    idArray.append(id)
                }
            }
            let bodyData: [String:Any] = [
                "message" : idArray
            ]
            
            var url = "/message/delete"
            if forEveryone {
                url = "/message/deleteEveryone"
            }
            circuitChatRequest(url, method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success(let data):
                    for chatData in chat {
                        if let index = self.userChatDataArray?.firstIndex(of: chatData) {
                            self.userChatDataArray?[index].isSelected = false
                        }
                    }
                    self.toastMessage = data.message
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func starredMessage(_ chat: UserChatData) {
            let bodyData: [String:Any] = [
                "message" : [chat.id]
            ]
            var url = "/message/starred"
            if chat.starred ?? false {
                url = "/message/unstarred"
            }
            circuitChatRequest(url, method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
                switch result {
                case .success(let data):
                    if let index = self.userChatDataArray?.firstIndex(of: chat) {
                        self.userChatDataArray?[index].starred = chat.starred ?? false ? false : true
                    }
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func getFileExtension(from data: Data) -> String? {
            // Create a temporary file URL with a random name and the data
            let temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
            
            do {
                // Write the data to the temporary file
                try data.write(to: temporaryURL)
                
                // Get the path extension using the temporary file URL
                let fileExtension = temporaryURL.pathExtension
                
                // Delete the temporary file
                try FileManager.default.removeItem(at: temporaryURL)
                
                return fileExtension
            } catch {
                print("Error: \(error)")
                return nil
            }
        }
        
        func sendMessage(selectedMedia: SelectedMedia? = nil, imageURLs: [URL]? = nil, videoURL: URL? = nil, audioURL: URL? = nil, docURL: URL? = nil, to: String, contentType: String, text: String? = nil, receiverType: String, replyMessage: UserChatData? = nil) {
            
            var bodyData: [String:Any] = [
                "to" : to,
                "type" : contentType,
                "receiverType" : receiverType
            ]
            
            if let text = text {
                bodyData.updateValue(text as Any, forKey: "text")
            }
            
            if let replyMessage = replyMessage {
                if let id = replyMessage.id {
                    bodyData.updateValue(id as Any, forKey: "reply")
                }
            }
            
            var dataType = ""
            var dataExtension = ""
            
            //Send Image
            var fileData: [String: Data] = [:]
            if let imageURLs = imageURLs {
                for imageURL in imageURLs {
                    do {
                        let imageData = try Data(contentsOf: imageURL)
                        dataType = "image"
                        dataExtension = imageURL.pathExtension
                        bodyData.updateValue("image", forKey: "type")
                        fileData.updateValue(imageData, forKey: "file")
                        // Now "imageData" contains the image file data
                    } catch {
                        print("Error reading video data: \(error.localizedDescription)")
                    }
                }
            }
            
            if let selectedMedia = selectedMedia {
                for mediaObject in selectedMedia.items {
                    if let imageData = mediaObject.mediaData {
                        dataType = mediaObject.mediaType
                        dataExtension = mediaObject.mediaExtension
                        bodyData.updateValue(mediaObject.mediaType, forKey: "type")
                        fileData.updateValue(imageData, forKey: "file")
                        // Now "imageData" contains the image file data
                    } else if let videoData = mediaObject.mediaURL {
                        do {
                            let videoData = try Data(contentsOf: videoData)
                            dataType = mediaObject.mediaType
                            dataExtension = mediaObject.mediaExtension
                            bodyData.updateValue(mediaObject.mediaType, forKey: "type")
                            fileData.updateValue(videoData, forKey: "file")
                            // Now "videoData" contains the video file data
                        } catch {
                            print("Error reading video data: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            //Send Video
            if let videoURL = videoURL {
                do {
                    let videoData = try Data(contentsOf: videoURL)
                    dataType = "video"
                    dataExtension = videoURL.pathExtension
                    bodyData.updateValue("video", forKey: "type")
                    fileData.updateValue(videoData, forKey: "file")
                    // Now "videoData" contains the video file data
                } catch {
                    print("Error reading video data: \(error.localizedDescription)")
                }
            }
            
            //Send Audio
            if let audioURL = audioURL {
                do {
                    let audioData = try Data(contentsOf: audioURL)
                    dataType = "audio"
                    dataExtension = audioURL.pathExtension
                    bodyData.updateValue("audio", forKey: "type")
                    fileData.updateValue(audioData, forKey: "file")
                    // Now "audioData" contains the audio file data
                } catch {
                    print("Error reading audio data: \(error.localizedDescription)")
                }
            }
            
            //Send Document
            if let docURL = docURL {
                do {
                    let applicationData = try Data(contentsOf: docURL)
                    dataType = "application"
                    dataExtension = docURL.pathExtension
                    bodyData.updateValue("application", forKey: "type")
                    fileData.updateValue(applicationData, forKey: "file")
                    // Now "applicationData" contains the application file data
                } catch {
                    print("Error reading application data: \(error.localizedDescription)")
                }
            }
            
            circuitChatRequest("/message", method: .post, bodyData: bodyData, fileData: fileData, dataType: dataType, dataExtension: dataExtension, model: UserChatData.self) { result in
                switch result {
                case .success(let data):
                    if let message = data.message {
                        self.toastMessage = message
                    }
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
            
        }
        
        func hasReachedEnd(of lastChatData: UserChatData, array: [UserChatData]) -> Bool {
            return array.last == lastChatData
        }
        
        func fetchChatMessages(lastChatData: Chat, password: String? = nil) {
            var bodyData: [String:Any]?
            if let password = password {
                bodyData = ["password": password]
            }
            requestFetching = true
            circuitChatRequest("/message/\(lastChatData.id)/\(lastChatData.chatType ?? "user")?page=\(pageCount)&limit=\(limitCount)", method: .post, bodyData: bodyData, model: UserChatResponse.self) { result in
                
                switch result {
                case .success(let data):
                    if data.menu.data.count > 0 {
                        self.userChat = data.menu
                        
                        if self.userChatDataArray == nil {
                            self.userChatDataArray = data.menu.data.reversed()
                        } else {
                            var added = false
                            for chatData in data.menu.data {
                                if !added {
                                    self.scrolledUserChatData = chatData
                                    added = true
                                }
                                self.userChatDataArray?.insert(chatData, at: 0)
                            }
                        }
                        self.pageCount += 1
                        
                        self.changeDataModel()
                        
                        self.requestFetching = false
                        
                    }
                    print("success")
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func changeDataModel() {
            
            var showDateText = self.userChatDataArray?.last?.createdAt?.chatDateFormat

            var showUserName = self.userChatDataArray?.last?.senderDetails?.name

            var showUserImage = self.userChatDataArray?.last?.senderDetails?.avatar

            if let userChatDataArray = self.userChatDataArray {
                for data in userChatDataArray.reversed() { // REVERSING THE ARRAY

                    //MARK: Date Grouping
                    if let date = data.createdAt?.chatDateFormat {
                        if let index = userChatDataArray.firstIndex(of: data) {
                            self.userChatDataArray?[index].dateText = date
                            if index<userChatDataArray.count-1 && showDateText == date {
                                self.userChatDataArray?[index+1].dateText = ""
                            }
                            showDateText = date
                        }
                    }

                    //MARK: User name Grouping in GROUP Chat
//                    if let name = data.senderDetails?.name {
//                        if let index = userChatDataArray.firstIndex(of: data) {
//                            if index<userChatDataArray.count-1 && showUserName == name {
//                                self.userChatDataArray?[index+1].senderDetails?.name = ""
//                            }
//                            showUserName = name
//                        }
//                    }

                    //MARK: User Image Grouping in GROUP Chat
//                    if let avatar = data.senderDetails?.avatar {
//                        if let index = userChatDataArray.firstIndex(of: data) {
//                            if index<userChatDataArray.count-1 && showUserImage==avatar {
//                                self.userChatDataArray?[index].senderDetails?.avatar = ""
//                            }
//                            showUserImage = avatar
//                        }
//                    }
                }
            }
            
        }
    }
//}
