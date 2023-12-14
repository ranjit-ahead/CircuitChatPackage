//
//  NewChatViewData.swift
//  Chat
//
//  Created by Apple on 18/09/23.
//

import Foundation

// MARK: - NewChatResponse
struct NewChatResponse: Codable {
    let menu: AddMembersMenu
}

// MARK: - AddMembersMenu
struct AddMembersMenu: Codable {
    
    let addMember: NewChatMenu?
    let createNewGroup: NewChatMenu?
    
    let closeIcon: String?
    var navigationTitle: String?
    let next: String?
    let search: FetchResponse?
    let createGroup: FetchResponse?
    let done: FetchResponse?
    let frequentlyContacted: NewChatContactsData?
    let contacts: NewChatContacts?
}

// MARK: - NewChatMenu
struct NewChatMenu: Codable {
    let closeIcon: String?
    var navigationTitle: String?
    let next: String?
    let search: FetchResponse?
    let createGroup: FetchResponse?
    let frequentlyContacted: NewChatContactsData?
    let contacts: NewChatContacts?
    
    let create: FetchResponse?
    let avatarIcon: String?
    let avatarOptions: [FetchResponse]?
    let nameInput: FetchResponse?
    let groupDescription: FetchResponse?
    let selectType: SelectType?
    let passwordInput: FetchResponse?
    let selectedCount: FetchResponse?
}

//MARK: SelectType
struct SelectType: Codable {
    let label: String?
    let select: String?
    let options: [FetchResponse]?
    let cancel: String?
}

// MARK: - NewChatContacts
struct NewChatContacts: Codable {
    let hashData, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z : NewChatContactsData?
    
    var requiredArray: [NewChatContactsData] = []
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let array = try container.decodeIfPresent(NewChatContactsData.self, forKey: .hashData) {
            requiredArray = [array]
        }
                
        // Extract all values for keys "A" to "Z"
        let allValues = try (0...25).map { try container.decodeIfPresent(NewChatContactsData.self, forKey: CodingKeys(rawValue: String(UnicodeScalar($0 + 65)!))!) }
        
        // Filter out nil values and assign to requiredArray
        requiredArray.append(contentsOf: allValues.compactMap { $0 })
        
        // Initialize all properties
        hashData = nil
        a = nil
        b = nil
        c = nil
        d = nil
        e = nil
        f = nil
        g = nil
        h = nil
        i = nil
        j = nil
        k = nil
        l = nil
        m = nil
        n = nil
        o = nil
        p = nil
        q = nil
        r = nil
        s = nil
        t = nil
        u = nil
        v = nil
        w = nil
        x = nil
        y = nil
        z = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case hashData = "#"
        case a = "A"
        case b = "B"
        case c = "C"
        case d = "D"
        case e = "E"
        case f = "F"
        case g = "G"
        case h = "H"
        case i = "I"
        case j = "J"
        case k = "K"
        case l = "L"
        case m = "M"
        case n = "N"
        case o = "O"
        case p = "P"
        case q = "Q"
        case r = "R"
        case s = "S"
        case t = "T"
        case u = "U"
        case v = "V"
        case w = "W"
        case x = "X"
        case y = "Y"
        case z = "Z"
    }
}

// MARK: - NewChatContactsData
struct NewChatContactsData: Codable, Identifiable {
    let id: String
    let results: [Chat]
    
    enum CodingKeys: String, CodingKey {
        case id = "title"
        case results = "results"
    }
    
}
