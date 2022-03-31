//
//  AppFont.swift
//  Base_Movie
//
//  Created by Viet Phan on 29/03/2022.
//

import Foundation
import UIKit

struct AppFont {
    
    enum FontName: String {
        
        case black = "Poppins-Black"
        case blackItalic = "Poppins-BlackItalic"
        case bold = "Poppins-Bold"
        case boldItalic = "Poppins-BoldItalic"
        case extraBold = "Poppins-ExtraBold"
        case extraBoldItalic = "Poppins-ExtraBoldItalic"
        case extraLight = "Poppins-ExtraLight"
        case extraLightItalic = "Poppins-ExtraLightItalic"
        case italic = "Poppins-Italic"
        case light = "Poppins-Light"
        case lightItalic = "Poppins-LightItalic"
        case medium = "Poppins-Medium"
        case mediumItalic = "Poppins-MediumItalic"
        case regular = "Poppins-Regular"
        case semiBold = "Poppins-SemiBold"
        case semiBoldItalic = "Poppins-SemiBoldItalic"
        case thin = "Poppins-Thin"
        case thinItalic = "Poppins-ThinItalic"
    }
    
    static func getFont(fontName: FontName, fontSize: CGFloat) -> UIFont {
        return UIFont(name: fontName.rawValue, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
}
