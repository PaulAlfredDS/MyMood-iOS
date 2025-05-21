//
//  Color.swift
//  MoodTracker
//
//  Created by Paul on 5/21/25.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    //text colors
    let accentButtonText = Color("AccentButtonTextColor")
    let bodyText = Color("BodyTextColor")
    let disabledText = Color("DisabledTextColor")
    let headingText = Color("HeadingTextColor")
    let primaryButtonText = Color("PrimaryButtonTextColor")
    let secondaryButtonText = Color("SecondaryButtonTextColor")
    let subText = Color("SubtextTextColor")
    let tertiaryText = Color("TertiaryTextColor")
    
    //main colors
    let accent = Color("AccentColor")
    let primary = Color("PrimaryColor")
    let border = Color("BorderColor")
    let secondary = Color("SecondaryColor")
    let tertiary = Color("TertiaryColor")
    let shadow = Color("ShadowColor")
}
