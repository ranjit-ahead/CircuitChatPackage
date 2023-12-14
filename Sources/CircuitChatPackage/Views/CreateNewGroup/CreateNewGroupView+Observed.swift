//
//  CreateNewGroupView+Observed.swift
//  Chat
//
//  Created by Apple on 21/09/23.
//

import Foundation
import SwiftUI

extension CreateNewGroupView {
    class Observed: ObservableObject {
        
//        @Published var apiResponse: CreateGroupResponse?
        
        var socketIO: CircuitChatSocketManager?
        
        enum PrivacySelection: Int {
            case privacy = 0
        }
        
        func createGroup(imageURL: URL? = nil, name: String, description: String? = nil, groupPrivacy: Int?, password: String? = nil, users: [Chat], completion: @escaping () -> ()) {
            
            guard groupPrivacy != nil else {
                return
            }
            
            var bodyData: [String:Any] = [
                "name" : name,
                "type" : "\(groupPrivacy!)"
            ]
            
            if groupPrivacy==2 && (password==nil) {
                return
            }
            
            if let description = description {
                bodyData.updateValue(description as Any, forKey: "metadata")
            }
            if let password = password {
                bodyData.updateValue(password as Any, forKey: "password")
            }
            
            for lastChatData in users {
                let index = users.firstIndex(of: lastChatData) ?? 0
                bodyData.updateValue(lastChatData.id as Any, forKey: "users[\(index)]")
            }
            
            var dataType = ""
            var dataExtension = ""
            var fileData: [String: Data] = [:]
            if let imageURL = imageURL {
                do {
                    let imageData = try Data(contentsOf: imageURL)
                    dataType = "image"
                    dataExtension = imageURL.pathExtension
                    fileData.updateValue(imageData, forKey: "avatar")
                    // Now "imageData" contains the image file data
                } catch {
                    print("Error reading video data: \(error.localizedDescription)")
                }
            }
            
            circuitChatRequest("/group/create", method: .post, bodyData: bodyData, fileData: fileData, dataType:dataType, dataExtension: dataExtension ,model: CreateGroupResponse.self) { result in
                switch result {
                case .success(let data):
                    print(data)
//                    self.apiResponse = data
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
                completion()
            }
        }
        
    }
    
}

// MARK: - CreateGroupResponse
struct CreateGroupResponse: Codable {
    let settings: CreateGroupSettings?
    let id, name: String?
    let avatar: String?
    let type: Int?
    let status: Bool?
    let password, createdAt, updatedAt: String?
    let link: String?
    let qrcode: String?

    enum CodingKeys: String, CodingKey {
        case settings
        case id = "_id"
        case name, avatar, type, status, password, createdAt, updatedAt, link, qrcode
    }
}

// MARK: - CreateGroupSettings
struct CreateGroupSettings: Codable {
    let member: CreateGroupMember?
    let admin: CreateGroupAdmin?
}

// MARK: - Admin
struct CreateGroupAdmin: Codable {
    let approveMember: Bool?
}

// MARK: - Member
struct CreateGroupMember: Codable {
    let editDetails, sendMessage, addMember: Bool?
}
