//
//  Data.swift
//  Chat
//
//  Created by Apple on 18/10/23.
//

import Foundation

extension Data {
    mutating func append(_ s: String) {
        self.append(s.data(using: .utf8)!)
    }
}
