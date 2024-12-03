//
//  KeyboardInfo.swift
//  RetsTalk
//
//  Created by Byeongjo Koo on 12/2/24.
//

import UIKit

struct KeyboardInfo {
    var frame: CGRect
    let animationDuration: TimeInterval
    
    init?(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return nil }
        
        self.frame = frame
        self.animationDuration = animationDuration
    }
}
