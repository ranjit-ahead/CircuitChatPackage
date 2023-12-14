//
//  UserInfoModel.swift
//  Chat
//
//  Created by Apple on 31/10/23.
//

import Foundation

// MARK: - UserInfoModel
struct UserInfoModel: Codable {
    let menus: [FetchResponse]?
    let data: UserInfoData?
}

// MARK: - UserInfoData
struct UserInfoData: Codable {
    let id, name, email: String?
    let status: Int?
    let about: String?
    let avatar: String?
    let metadata: String?
    let mediaCount, staredCount: Int?
//    let mute: [JSONAny]?
    let commonGroupCount: Int?
    let groupProfiles: [UserDetail]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, email, status, about, avatar, metadata, mediaCount, staredCount, commonGroupCount, groupProfiles
    }
}
