//
//  MainTabViewData.swift
//  Chat
//
//  Created by Apple on 04/09/23.
//

import Foundation

// MARK: - MainTabViewData
struct MainTabViewData: Codable {
    let token: String
    let user: MainTabViewUser
    let menu: MainTabViewMenu
}

// MARK: - MainTabViewMenu
struct MainTabViewMenu: Codable {
    let successIcon, backwordArrowIcon, forwardArrowIcon: String?
    let tabBar: [FetchResponse]?
}

// MARK: - ApiRequest
struct ApiRequest {
    var apiURL: String
    
    var method: String
    var apiMethod: HTTPMethod
    
    init(apiURL: String?, method: String?) {
        self.apiURL = apiURL ?? ""
        self.method = method ?? ""
        self.apiMethod = method=="GET" ? .get : .post
    }
}

// MARK: - FetchResponse
struct FetchResponse: Codable, Identifiable, Equatable {
    
    static func == (lhs: FetchResponse, rhs: FetchResponse) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String?
    let label, label2: String?
    let labelSelected: String?
    let apiURL: String?
    let apiURLSelected: String?
    let apiMethod: String?
    let icon: String?
    let iconSelected: String?
    let count: Int?
    let body: APIBody?
    let backgroundColor: String?
    let placeholder: String?
    let value: Int?
    
    let subDialog: DialogView?
    let muteDialog: DialogView?
    let unMuteDialog: DialogView?
    let reportUserDialog: DialogView?
    let reportGroupDialog: DialogView?
    let deleteDialog: DialogView?
    let exitDialog: DialogView?
    let blockDialog: DialogView?
    let unblockDialog: DialogView?

    enum CodingKeys: String, CodingKey {
        case id = "key"
        case label, label2, labelSelected
        case apiURL = "apiUrl"
        case apiURLSelected = "apiUrlSelected"
        case apiMethod, icon, iconSelected, count, body, backgroundColor, placeholder, value
        
        case subDialog, muteDialog, unMuteDialog, reportUserDialog, reportGroupDialog, deleteDialog, exitDialog, blockDialog, unblockDialog
    }
}

//MARK: DialogView
struct DialogView: Codable {
    let icon: String?
    let innerIcons: [FetchResponse]?
    let key: String?
    let label: String?
    let description: String?
    let confirmText: String?
    let buttons: [FetchResponse]?
    let apiUrl: String?
    let apiMethod: String?
    let cancel: String?
}

// MARK: - MainTabViewUser
struct MainTabViewUser: Codable {
    let id, email, name, number: String?
    let password, createdAt, updatedAt: String?
    let status: Int?
    let active: Bool?
    let lastActive: String?
    let image: String?
    let role: String?
    let tags, metadata: String?
    let avatar: String?
    let token, rolePermission: String?
    let verified: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email, name, number, password, createdAt, updatedAt, status, active, lastActive, image, role, tags, metadata, avatar, token, rolePermission, verified
    }
}


