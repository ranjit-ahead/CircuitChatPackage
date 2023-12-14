//
//  String.swift
//  Chat
//
//  Created by Apple on 22/08/23.
//

import Foundation
import UIKit

extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        
        return ceil(boundingBox.height)
    }
    
    func htmlToString() -> String {
        return  try! NSAttributedString(data: self.data(using: .utf8)!,
                                        options: [.documentType: NSAttributedString.DocumentType.html],
                                        documentAttributes: nil).string
    }
    var htmlToAttributedString: NSMutableAttributedString? {

        guard let data = data(using: .utf8) else { return nil }
        
        do {
            return try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var onlineDateFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        if let showDate = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            if calendar.isDate(showDate, inSameDayAs: today) {
                // If the date is today, return the time in "HH:mm" format
                dateFormatter.dateFormat = "hh:mm a"
                return "today at \(dateFormatter.string(from: showDate))"
            } else if let daysAgo = calendar.dateComponents([.day], from: showDate, to: today).day, daysAgo == 1 {
                // If the date is yesterday, return "Yesterday"
                return "Yesterday"
            } else if let daysAgo = calendar.dateComponents([.day], from: showDate, to: today).day, daysAgo <= 7 {
                // If the date is within a week, return the day of the week (yesterday, Saturday, etc.)
                let dayOfWeek = dateFormatter.weekdaySymbols[calendar.component(.weekday, from: showDate) - 1]
                return dayOfWeek
            } else {
                // For other dates, return the date in "dd/MM/yyyy" format
                dateFormatter.dateFormat = "dd/MM/yyyy"
            }
            
            return dateFormatter.dateFormat ?? dateFormatter.string(from: showDate)
        }
        
        return "" // Return an empty string for invalid input
    }
    
    var chatDateFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        if let showDate = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            if calendar.isDate(showDate, inSameDayAs: today) {
                // If the date is today, return the time in "HH:mm" format
                dateFormatter.dateFormat = "HH:mm"
                return "Today"
            } else if let daysAgo = calendar.dateComponents([.day], from: showDate, to: today).day, daysAgo <= 1 {
                // If the date is yesterday, return "Yesterday"
                return "Yesterday"
            } else if let daysAgo = calendar.dateComponents([.day], from: showDate, to: today).day, daysAgo <= 7 {
                // If the date is within a week, return the day of the week (yesterday, Saturday, etc.)
                let dayOfWeek = dateFormatter.weekdaySymbols[calendar.component(.weekday, from: showDate) - 1]
                return dayOfWeek
            } else {
                // For other dates, return the date in "dd/MM/yyyy" format
                dateFormatter.dateFormat = "dd/MM/yyyy"
            }
            
            return dateFormatter.string(from: showDate)
        }
        
        return "" // Return an empty string for invalid input
    }
    
    var readableDateFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        if let showDate = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            if calendar.isDate(showDate, inSameDayAs: today) {
                // If the date is today, return the time in "HH:mm" format
                dateFormatter.dateFormat = "HH:mm"
            } else if let daysAgo = calendar.dateComponents([.day], from: showDate, to: today).day, daysAgo <= 1 {
                // If the date is yesterday, return "Yesterday"
                return "Yesterday"
            } else if let daysAgo = calendar.dateComponents([.day], from: showDate, to: today).day, daysAgo <= 7 {
                // If the date is within a week, return the day of the week (yesterday, Saturday, etc.)
                let dayOfWeek = dateFormatter.weekdaySymbols[calendar.component(.weekday, from: showDate) - 1]
                return dayOfWeek
            } else {
                // For other dates, return the date in "dd/MM/yyyy" format
                dateFormatter.dateFormat = "dd/MM/yyyy"
            }
            
            return dateFormatter.string(from: showDate)
        }
        
        return "" // Return an empty string for invalid input
    }
    
    var readableDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        if let showDate = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "dd MMM yyyy"
            return dateFormatter.string(from: showDate)
        }
        
        return "" // Return an empty string for invalid input
    }

    var getTimeFormatInHourAndMin: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        if let showDate = dateFormatter.date(from: self) {
            
            dateFormatter.dateFormat = "HH:mm a"
            
            return dateFormatter.string(from: showDate)
        }
        
        return "" // Return an empty string for invalid input
    }
    
    var getMonthAndYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        if let showDate = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            
            // Get the month and year from the date
            let components = calendar.dateComponents([.year, .month], from: showDate)
            
            // Format the month and year as "MMMM yyyy" (e.g., "November 2023")
            dateFormatter.dateFormat = "MMMM yyyy"
            return dateFormatter.string(from: showDate)
        }
        
        return "" // Return an empty string for invalid input
    }

}
