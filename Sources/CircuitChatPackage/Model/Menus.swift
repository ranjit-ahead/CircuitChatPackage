//
//  Menus.swift
//  Chat
//
//  Created by Apple on 06/10/23.
//

import Foundation

// MARK: - Menus
struct Menus: Codable {
    let chat: MenusChat
    let message: MenusMessage
}

// MARK: - MenusChat
struct MenusChat: Codable {
    let apiURL, apiMethod: String
    let menu: [MenusChatMenu]

    enum CodingKeys: String, CodingKey {
        case apiURL = "apiUrl"
        case apiMethod, menu
    }
}

// MARK: - ChatMenu
struct MenusChatMenu: Codable {
    let type, key: String
    let menuFalse, menuTrue: MenusBoolean?
    let label, apiURL, apiMethod: String?

    enum CodingKeys: String, CodingKey {
        case type, key
        case menuFalse = "false"
        case menuTrue = "true"
        case label
        case apiURL = "apiUrl"
        case apiMethod
    }
}

// MARK: - MenusBoolean
struct MenusBoolean: Codable {
    let label, apiURL, apiMethod: String
    let apiBodyParams: [MenusAPIBodyParam]?

    enum CodingKeys: String, CodingKey {
        case label
        case apiURL = "apiUrl"
        case apiMethod, apiBodyParams
    }
}

// MARK: - MenusAPIBodyParam
struct MenusAPIBodyParam: Codable {
    let message: [String]
}

// MARK: - MenusMessage
struct MenusMessage: Codable {
    let menu: [MenusMessageMenu]
}

// MARK: - MenusMessageMenu
struct MenusMessageMenu: Codable {
    let type, key: String
    let label, apiURL, apiMethod: String?
    let apiParams: [MenusAPIParamElement]?
    let menuTrue, menuFalse: MenusBoolean?

    enum CodingKeys: String, CodingKey {
        case type, key, label
        case apiURL = "apiUrl"
        case apiMethod, apiParams
        case menuTrue = "true"
        case menuFalse = "false"
    }
}

enum MenusAPIParamElement: Codable {
    case apiParamClass(MenusAPIParamClass)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(MenusAPIParamClass.self) {
            self = .apiParamClass(x)
            return
        }
        throw DecodingError.typeMismatch(MenusAPIParamElement.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for APIParamElement"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .apiParamClass(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

// MARK: - APIParamClass
struct MenusAPIParamClass: Codable {
    let reply, to: String?
}
