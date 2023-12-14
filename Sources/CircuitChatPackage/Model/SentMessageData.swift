//
//  SentMessageData.swift
//  Chat
//
//  Created by Apple on 12/09/23.
//

import Foundation

// MARK: - SentMessageData
struct SentMessageData: Codable {
    var sender: String?
    var receiver: String?
    var receiverType: String?
    var contentType: String?
    var text: String?
    var edited: Bool?
    var deleted: Bool?
    var id: String?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case sender = "sender"
        case receiver = "receiver"
        case receiverType = "receiverType"
        case contentType = "contentType"
        case text = "text"
        case edited = "edited"
        case deleted = "deleted"
        case id = "_id"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}
