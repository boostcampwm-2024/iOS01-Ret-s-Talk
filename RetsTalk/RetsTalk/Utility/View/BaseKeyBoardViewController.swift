//
//  BaseKeyBoardViewController.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

import UIKit

class BaseKeyBoardViewController: BaseViewController {
    
    // MARK: ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardNotificationObservers()
    }
    
    // MARK: Keyboard observing
    
    private func addKeyboardNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: Keyboard event hanler
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard let keywordInfo = KeyboardInfo(notification: notification) else { return }
        
        handleKeyboardWillShowEvent(using: keywordInfo)
    }
    
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        guard var keywordInfo = KeyboardInfo(notification: notification) else { return }
        
        keywordInfo.frame = CGRect()
        handleKeyboardWillHideEvent(using: keywordInfo)
    }
    
    func handleKeyboardWillShowEvent(using keyboardInfo: KeyboardInfo) {}
    
    func handleKeyboardWillHideEvent(using keyboardInfo: KeyboardInfo) {}
}
