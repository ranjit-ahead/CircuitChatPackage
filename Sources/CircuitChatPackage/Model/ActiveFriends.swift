//
//  ActiveFriends.swift
//  Chat
//
//  Created by Apple on 21/08/23.
//

import Foundation

// MARK: - ActiveFriends
struct ActiveFriends: Codable {
    var data: [Chat]
    var count: Int?

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case count = "count"
    }
}

// MARK: - ActiveFriendsData
//struct ActiveFriendsData: Codable, Hashable {
//    var id: String
//    var email: String?
//    var name: String
//    var avatar: String?
//    var active: Bool?
//    var verified: Bool?
//
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case email = "email"
//        case name = "name"
//        case avatar = "avatar"
//        case active = "active"
//        case verified = "verified"
//    }
//}
