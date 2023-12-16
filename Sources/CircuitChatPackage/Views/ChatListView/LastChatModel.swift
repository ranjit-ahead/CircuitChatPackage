//
//  LastChatData.swift
//  Chat
//
//  Created by Apple on 19/08/23.
//

import Foundation

// MARK: - LastChatResponse
struct LastChatResponse: Codable {
    var menu: LastChatMenu
    let success: Bool?
    let message: String?
    
    static let example = LastChatResponse(menu: LastChatMenu.example, success: nil, message: nil)
}

// MARK: - LastChatMenu
struct LastChatMenu: Codable {
    let navigationTitle: String?
    let edit: FetchResponse?
    let editDescription: String?
    let doneDescription: String?
    let newChat: FetchResponse?
    let search: FetchResponse?
    let filter: FetchResponse?
    let filterIcon: FetchResponse?
    let filterTitle: String?
    let people, group: FetchResponse?
    var archived: FetchResponse?
    let onlineIcon, muteIcon, pinIcon, singleTick: String?
    let doubleTick, missedCall, groupCall, defaultGorupAvatar: String?
    let defaultPeopleAvatar: String?
    let swipeOptions: [SwipeOptions]?
    let count: Int?
    var chats: [LastChatData]
    let footer: [FetchResponse]?
    let protectedGroup: ProtectedGroup?
    let noData: FetchResponse?
    let you: String?
    let photo: String?
    let video: String?
    let audio: String?
    let document: String?
    let location: String?
    
    static let example = LastChatMenu(navigationTitle: nil, edit: nil, editDescription: nil, doneDescription: nil, newChat: nil, search: nil, filter: nil, filterIcon: nil, filterTitle: nil, people: nil, group: nil, archived: nil, onlineIcon: nil, muteIcon: nil, pinIcon: nil, singleTick: nil, doubleTick: nil, missedCall: nil, groupCall: nil, defaultGorupAvatar: nil, defaultPeopleAvatar: nil, swipeOptions: nil, count: nil, chats: [LastChatData.example], footer: nil, protectedGroup: nil, noData: nil, you: nil, photo: nil, video: nil, audio: nil, document: nil, location: nil)
}

// MARK: - SwipeOptions
struct SwipeOptions: Codable, Identifiable, Equatable {
    
    static func == (lhs: SwipeOptions, rhs: SwipeOptions) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let label: String?
    let labelSelected: String?
    let apiURL: String?
    let apiMethod: String?
    let icon: String?
    let count: Int?
    let apiQueryParams: APIQueryParams?
    let body: APIBody?
    let backgroundColor: String?

    enum CodingKeys: String, CodingKey {
        case id = "key"
        case label, labelSelected
        case apiURL = "apiUrl"
        case apiMethod, icon, count, body, apiQueryParams, backgroundColor
    }
}

// MARK: - ProtectedGroup
struct ProtectedGroup: Codable {
    let icon: String?
    let label: String?
    let type: Int?
    let submit: FetchResponse?
}

struct LastChatMoreMenu: Codable {
    let menu: [FetchResponse]?
    
    static let example = LastChatMoreMenu(menu: nil)
}

// MARK: - LastChatResponse
//struct LastChatResponse: Codable {
//    let formObject: [FormObject]
//    var data: [LastChatData]
//    let count: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case formObject = "formObject"
//        case data = "data"
//        case count = "count"
//    }
//}

// MARK: - LastChatData
struct LastChatData: Codable, Identifiable, Equatable, Hashable {
    var userChatData: UserChatData?
    var mute: Bool?
    var blocked: Bool?
    var chat: Chat
    var pin: Bool?
    var unread: Int = 0
    var apiUrl: String?
    let apiMethod: String?
    let menu: [FetchResponse]?
    var isSelected: Bool?
    var senderDetails: Chat?
    let protectedGroup: ProtectedGroupView?
    var fromMe: Bool?
    
    // Conform to Hashable by providing a hash(into:) method
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(userChatData)
        hasher.combine(unread)
        hasher.combine(chat)
        hasher.combine(pin)
        hasher.combine(mute)
        hasher.combine(blocked)
        hasher.combine(isSelected)
    }
    
    // Implement the Equatable method to specify how instances are compared for equality
    static func == (lhs: LastChatData, rhs: LastChatData) -> Bool {
        // Compare the properties of the two instances to determine equality
        // For example, if you have a unique identifier for each LastChatData object:
        return lhs.id == rhs.id && lhs.userChatData == rhs.userChatData && lhs.unread == rhs.unread && lhs.chat == rhs.chat && lhs.pin == rhs.pin && lhs.mute == rhs.mute && lhs.blocked == rhs.blocked && lhs.isSelected == rhs.isSelected
    }

    enum CodingKeys: String, CodingKey {
        case userChatData = "lastMessage"
        case mute = "mute"
        case blocked = "blocked"
        case chat = "chat"
        case pin = "pin"
        case unread = "unread"
        case apiUrl = "apiUrl"
        case apiMethod = "apiMethod"
        case menu = "menu"
        case isSelected = "isSelected"
        case senderDetails = "senderDetails"
        case protectedGroup = "protectedGroup"
    }
    
    var id: String {
        return chat.id  // Combine chat ID and apiUrl to make a unique identifier
    }
    
    static let example = LastChatData(chat: Chat.example, apiMethod: nil, menu: nil, protectedGroup: nil)
}

// MARK: - Chat
struct Chat: Codable, Hashable, Equatable, Identifiable {
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id && lhs.active == rhs.active && lhs.avatar == rhs.avatar && lhs.action == rhs.action
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(active)
    }
    
    let id: String
    let email: String?
    var name: String
    var avatar: String?
    var active: Bool?
    var action: String?
    let verified: Bool?
    let chatType: String?
    let protected: Bool?
    let lastActive: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email = "email"
        case name = "name"
        case avatar = "avatar"
        case active = "active"
        case verified = "verified"
        case chatType = "chatType"
        case protected = "protected"
        case lastActive = "lastActive"
    }
    
    static let example = Chat(id: "", email: nil, name: "", avatar: nil, active: nil, action: nil, verified: nil, chatType: nil, protected: nil, lastActive: nil)
}

struct ChatIDAndType {
    let id: String
    let chatType: String
}

// MARK: - MenuModel
//struct MenuModel: Codable {
//    let type: String?
//    let parts: [MenuModel]?
//    let id: String?
//    let name: String?
//    let apiUrl: String?
//    let apiMethod: String?
//    let label: String?
//
//    enum CodingKeys: String, CodingKey {
//        case type = "type"
//        case parts = "parts"
//        case id = "id"
//        case name = "name"
//        case apiUrl = "apiUrl"
//        case apiMethod = "apiMethod"
//        case label = "label"
//    }
//}

// MARK: - FormObject
struct FormObject: Codable {
    let type: String?
    let inputType: String?
    let id: String?
    let name: String?
    let placeholder: String?
    let apiUrl: String?
    let apiMethod: String?
    let apiQueryParams: APIQueryParams?
    let label: String?
    let parts: [FetchResponse]?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case inputType = "inputType"
        case id = "id"
        case name = "name"
        case placeholder = "placeholder"
        case apiUrl = "apiUrl"
        case apiMethod = "apiMethod"
        case apiQueryParams = "apiQueryParams"
        case label = "label"
        case parts = "parts"
    }
}

// MARK: - APIQueryParams
struct APIQueryParams: Codable {
    let search: String?
    let chatID, chatType: String?

    enum CodingKeys: String, CodingKey {
        case search = "search"
        case chatID = "chatId"
        case chatType
    }
}

// MARK: - APIBody
struct APIBody: Codable {
    let password: String?
}

//MARK: ProtectedGroupView
struct ProtectedGroupView: Codable {
    let icon: String?
    let label: String?
    let password: String?
    let submit: FetchResponse?
}
