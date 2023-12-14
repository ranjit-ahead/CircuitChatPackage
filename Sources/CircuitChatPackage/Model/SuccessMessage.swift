//
//  SuccessMessage.swift
//  Chat
//
//  Created by Apple on 27/09/23.
//

import Foundation

struct SuccessMessage: Codable {
    let success: Bool?
    let message: String
}

// MARK: - MessageDeleted
typealias MessageID = [String]
