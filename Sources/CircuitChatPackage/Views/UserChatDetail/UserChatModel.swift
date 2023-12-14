//
//  UserChat.swift
//  Chat
//
//  Created by Apple on 12/09/23.
//

import Foundation

// MARK: - UserChatResponse
struct UserChatResponse: Codable {
    var menu: UserChat
    let success: Bool?
    let message: String?
}

// MARK: - UserChat
struct UserChat: Codable {
    var data: [UserChatData]
    var count: Int?
    let stickerIcon: String?
    let cameraIcon:  String?
    let recordingIcon: String?
    let pauseIcon: String?
    let sendMessageIcon: String?
    let onlyAdmin: String?
    let cancel: String?
    let selected: String?
    let more: String?
    let moreMediaIcon: DialogView?
    let deleteDialog: [DialogView]?
    let footerDialog: [DialogView]?
    var blocked: Bool?
    let unBlock: DialogView?
    
    enum CodingKeys: String, CodingKey {
        case data = "messages"
        case count
        case stickerIcon
        case cameraIcon
        case recordingIcon
        case pauseIcon
        case sendMessageIcon
        case onlyAdmin
        case cancel
        case selected
        case more
        case moreMediaIcon
        case deleteDialog
        case footerDialog
        case blocked
        case unBlock
    }
}

// MARK: - UserChatData
struct UserChatData: Codable, Identifiable, Equatable, Hashable {
    static func == (lhs: UserChatData, rhs: UserChatData) -> Bool {
        return lhs.id == rhs.id && lhs.createdAt == rhs.createdAt && lhs.contentType == rhs.contentType && lhs.messageStatus == rhs.messageStatus && lhs.starred == rhs.starred
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(createdAt)
        hasher.combine(contentType)
        hasher.combine(messageStatus)
        hasher.combine(starred)
    }
    
    var id: String?
    var contentType: String?
    var text: String?
    var edited: Bool?
    var deleted: Bool?
    var createdAt: String?
    var updatedAt: String?
    var messageStatus: Int?
    var media: String?
    var starred: Bool?
    var fromMe: Bool?
    var menu: [UserChatMenu]?
    var sender: String?
    var receiver: String?
    var receiverType: String?
    var senderDetails: Chat?
    var receiverDetails: Chat?
    var dateText: String?
    var location: UserChatLocation?
    var contact: [ContactElement]?
    var reply: UserChatReplyData?
    var dialog: [FetchResponse]?
    var isSelected: Bool? = false
    var message: String?
    
    var forward: UserChatData? { boxedReference?.wrappedValue }
    let boxedReference: Box<UserChatData>?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case contentType = "contentType"
        case text = "text"
        case edited = "edited"
        case deleted = "deleted"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case messageStatus = "message_status"
        case media = "media"
        case starred = "starred"
        case fromMe = "fromMe"
        case menu = "menu"
        case sender = "sender"
        case receiver = "receiver"
        case receiverType = "receiverType"
        case senderDetails = "user"
        case receiverDetails = "receiverDetails"
        case location = "location"
        case contact = "contact"
        case reply = "reply"
        case dialog
        case message
        case boxedReference = "forward"
    }
    
    var uniqueId: String {
        return "\(UUID())"//id + createdAt + contentType // Combine chat ID and apiUrl to make a unique identifier
    }
}

class Box<T: Codable>: Codable {
    let wrappedValue: T
    required init(from decoder: Decoder) throws {
        wrappedValue = try T(from: decoder)
    }
    
    func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

struct UserChatReplyData: Codable, Identifiable, Equatable, Hashable {
    static func == (lhs: UserChatReplyData, rhs: UserChatReplyData) -> Bool {
        return lhs.id == rhs.id && lhs.createdAt == rhs.createdAt && lhs.contentType == rhs.contentType && lhs.messageStatus == rhs.messageStatus && lhs.starred == rhs.starred
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(createdAt)
        hasher.combine(contentType)
        hasher.combine(messageStatus)
        hasher.combine(starred)
    }
    
    var id: String?
    var contentType: String?
    var text: String?
    var edited: Bool?
    var deleted: Bool?
    var createdAt: String?
    var updatedAt: String?
    var messageStatus: Int?
    var media: String?
    var starred: Bool?
    var fromMe: Bool?
    var menu: [UserChatMenu]?
    var sender: String?
    var receiver: String?
    var receiverType: String?
    var senderDetails: Chat?
    var receiverDetails: Chat?
    var dateText: String?
    var location: UserChatLocation?
    var contact: [ContactElement]?
    var isSelected: Bool? = false

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case contentType = "contentType"
        case text = "text"
        case edited = "edited"
        case deleted = "deleted"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case messageStatus = "message_status"
        case media = "media"
        case starred = "starred"
        case fromMe = "fromMe"
        case menu = "menu"
        case sender = "sender"
        case receiver = "receiver"
        case receiverType = "receiverType"
        case senderDetails = "user"
        case receiverDetails = "receiverDetails"
        case location = "location"
        case contact = "contact"
    }
    
    var uniqueId: String {
        return "\(UUID())"//id + createdAt + contentType // Combine chat ID and apiUrl to make a unique identifier
    }
}

//MARK: - UserChatLocation
struct UserChatLocation: Codable{
    let locationType: String?
    let longitude: Double?
    let latitude: Double?
    let status: Int?
    let endTime: String?
}

// MARK: - UserChatMenu
struct UserChatMenu: Codable {
    var key: String?
    var label: String?
    var apiUrl: String?
    var apiMethod: String?
    var apiParams: UserChatAPIParams?

    enum CodingKeys: String, CodingKey {
        case key = "key"
        case label = "label"
        case apiUrl = "apiUrl"
        case apiMethod = "apiMethod"
        case apiParams = "apiParams"
    }
}

// MARK: - UserChatAPIParams
struct UserChatAPIParams: Codable {
    var messageId: String?
    var text: String?
    var reply: String?

    enum CodingKeys: String, CodingKey {
        case messageId = "messageId"
        case text = "text"
        case reply = "reply"
    }
}

// MARK: - ContactElement
struct ContactElement: Codable {
    let name: String
    let numbers: [ContactNumber]
    let id: String

    enum CodingKeys: String, CodingKey {
        case name, numbers
        case id = "_id"
    }
}

// MARK: - Number
struct ContactNumber: Codable {
    let number, label, id: String

    enum CodingKeys: String, CodingKey {
        case number, label
        case id = "_id"
    }
}
