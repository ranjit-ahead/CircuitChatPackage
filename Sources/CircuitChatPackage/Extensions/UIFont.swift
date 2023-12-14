//
//  UIFont.swift
//  Chat
//
//  Created by Apple on 22/08/23.
//

import UIKit
import SwiftUI

extension UIFont {
    class func preferredFont(from font: Font) -> UIFont {
        let uiFont: UIFont
        
        switch font {
        case .largeTitle:
            uiFont = UIFont.preferredFont(forTextStyle: .largeTitle)
        case .title:
            uiFont = UIFont.preferredFont(forTextStyle: .title1)
        case .title2:
            uiFont = UIFont.preferredFont(forTextStyle: .title2)
        case .title3:
            uiFont = UIFont.preferredFont(forTextStyle: .title3)
        case .headline:
            uiFont = UIFont.preferredFont(forTextStyle: .headline)
        case .subheadline:
            uiFont = UIFont.preferredFont(forTextStyle: .subheadline)
        case .callout:
            uiFont = UIFont.preferredFont(forTextStyle: .callout)
        case .caption:
            uiFont = UIFont.preferredFont(forTextStyle: .caption1)
        case .caption2:
            uiFont = UIFont.preferredFont(forTextStyle: .caption2)
        case .footnote:
            uiFont = UIFont.preferredFont(forTextStyle: .footnote)
        case .body:
            fallthrough
        default:
            uiFont = UIFont.preferredFont(forTextStyle: .body)
        }
        
        return uiFont
    }
}

extension Font {
    
    //Open Sans Font
    static func regularFont(_ size: CGFloat) -> Font {
        return Font.custom("OpenSans-Regular", size: size)
    }
    static func mediumFont(_ size: CGFloat) -> Font {
        return Font.custom("OpenSans-Medium", size: size)
    }
    static func semiBoldFont(_ size: CGFloat) -> Font {
        return Font.custom("OpenSans-SemiBold", size: size)
    }
    static func boldFont(_ size: CGFloat) -> Font {
        return Font.custom("OpenSans-Bold", size: size)
    }
    static func extraBoldFont(_ size: CGFloat) -> Font {
        return Font.custom("OpenSans-ExtraBold", size: size)
    }
    
    //Poppins Font
    static func regularPoppins(_ size: CGFloat) -> Font {
        return Font.custom("Poppins-Regular", size: size)
    }
}
