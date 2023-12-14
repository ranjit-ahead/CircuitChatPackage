//
//  Int64.swift
//  Chat
//
//  Created by Apple on 11/10/23.
//

import Foundation

extension Int64 {
    var convertBytesToGBMBKB: String {
        if self > 1024 * 1024 * 1024 {
            let gigabytes = Double(self) / (1024 * 1024 * 1024)
            return String(format: "%.2f GB", gigabytes)
        } else if self > 1024 * 1024 {
            let megabytes = Double(self) / (1024 * 1024)
            return String(format: "%.2f MB", megabytes)
        } else if self > 1024 {
            let kilobytes = Double(self) / 1024
            return String(format: "%.2f KB", kilobytes)
        } else {
            return "\(self) bytes"
        }
    }
}
