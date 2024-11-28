//
//  BaseKeyBoardViewController.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

import UIKit

class BaseKeyBoardViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardObservers()
        addTapGestureOfDismissingKeyboard()
    }
    
    // MARK: TapGesture of KeyboardDismissing
    
    private func addTapGestureOfDismissingKeyboard() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: KeyboardObserving
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowAndHide(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowAndHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShowAndHide(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardWillUpdateConstraint(keyboardHeight: keyboardFrame.height)
        }
    }
    
    /// 이 함수는 키보드 호출 시 높이를 전달받아 레이아웃을 조정합니다.
    /// - Parameter keyboardHeight: 키보드 높이
    func keyboardWillUpdateConstraint(keyboardHeight: CGFloat) { }
}
