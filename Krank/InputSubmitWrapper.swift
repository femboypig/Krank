//
//  InputSubmitWrapper.swift
//  Krank
//

import Foundation

class InputSubmitWrapper: NSObject {
    let action: (String) -> Void
    init(_ action: @escaping (String) -> Void) {
        self.action = action
    }
}
