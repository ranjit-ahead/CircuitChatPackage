//
//  GroupInfoModel.swift
//  Chat
//
//  Created by Apple on 30/10/23.
//

import Foundation

// MARK: - GroupInfoModel
struct GroupInfoModel: Codable {
    let success: Bool?
    let menus: [FetchResponse]?
    let editMenu: [FetchResponse]?
    let data: GroupInfoData
    let message: String?
}

// MARK: - GroupInfoData
struct GroupInfoData: Codable {
    let id, name, about: String?
    let verified: Bool?
    let type: Int?
    let avatar: String?
//    let settings: Settings?
    let createdAt, updatedAt: String?
    let mediaCount, staredCount: Int?
    let isAdmin: Bool?
    let mute: [UserDetail]?
    let countMembers, countPending: Int?
    let adminDetail: [UserDetail]?
    let groupAllUserDetails: [UserDetail]?
    let createdBy: Chat?
    var metadata: String?
    let aboutOptions: [AboutOptions]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, about, verified, type, avatar, createdAt, updatedAt, mediaCount, staredCount, isAdmin, mute, countMembers, countPending, adminDetail, groupAllUserDetails, createdBy, metadata, aboutOptions
    }
}

//MARK: AboutOptions
struct AboutOptions: Codable, Hashable {
    let about: String
    let status: Int
}

// MARK: - UserDetail
struct UserDetail: Codable, Hashable {
    let id, email, uid, name: String?
    let number, password: String?
    let createdAt: String?
    let updatedAt: String?
    let active: Bool?
    let lastActive: String?
    let avatar: String?
    let link: String?
    let metadata, rolePermission: String?
    let verified: Bool?
    let about: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email, uid, name, number, password, createdAt, updatedAt, active, lastActive, avatar, link, metadata, rolePermission, verified, about
    }
}
