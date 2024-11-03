//
//  ToolBarModifier.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/3/24.
//


import SwiftUI
import UIKit

struct ToolBarModifier: ViewModifier {
    
    init(backgroundColor: UIColor = .systemBackground, foregroundColor: UIColor = .blue, tintColor: UIColor?, withSeparator: Bool = true){
        let toolBarAppearance = UITabBarAppearance()
        toolBarAppearance.configureWithTransparentBackground()
        toolBarAppearance.backgroundColor = backgroundColor
        if withSeparator {
            toolBarAppearance.shadowColor = .clear
        }

        UITabBar.appearance().standardAppearance = toolBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = toolBarAppearance
        
        if let tintColor = tintColor {
            UIToolbar.appearance().tintColor = tintColor
        }
    }
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func tabBarModifier(backgroundColor: UIColor = .systemBackground, foregroundColor: UIColor = .label, tintColor: UIColor?, withSeparator: Bool) -> some View {
        self.modifier(ToolBarModifier(backgroundColor: backgroundColor, foregroundColor: foregroundColor, tintColor: tintColor, withSeparator: withSeparator))
    }
}
