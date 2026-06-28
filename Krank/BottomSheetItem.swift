//
//  BottomSheetItem.swift
//  Krank
//

import UIKit

class BottomSheetItem: NSObject {
    let title: String
    let iconName: String
    let isDestructive: Bool
    let action: () -> Void
    
    init(title: String, iconName: String, isDestructive: Bool, action: @escaping () -> Void) {
        self.title = title
        self.iconName = iconName
        self.isDestructive = isDestructive
        self.action = action
    }
}
