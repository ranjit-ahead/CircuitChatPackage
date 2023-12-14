//
//  ViewModifiers.swift
//  Chat
//
//  Created by Apple on 01/11/23.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
