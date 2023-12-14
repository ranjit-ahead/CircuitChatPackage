//
//  UserAction.swift
//  Chat
//
//  Created by Apple on 05/10/23.
//

import Foundation

// MARK: - UserAction
struct UserAction: Codable, Equatable {
    let chat, action, label: String
    let user: Chat?
}

struct SocketChatResponse: Codable, Equatable {
    static func == (lhs: SocketChatResponse, rhs: SocketChatResponse) -> Bool {
        return lhs.chat == rhs.chat
    }
    
    let chat: [String]?
    let avatar: String?
    let menu: SocketMenus?
    let unread_count: Int?
    
    enum CodingKeys: String, CodingKey {
        case chat = "chat_id"
        case avatar
        case menu, unread_count
    }
}

struct SocketMenus: Codable {
    let archived: FetchResponse?
}
