//
//  ChattingViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit

final class ChattingViewController: UIViewController {
    private let chatView = ChatView()
    private var chatViewBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatViewSetUp()
        addKeyboardObservers()
    }
    
    private func chatViewSetUp() {
        view.addSubview(chatView)
        chatView.setUp()
        chatView.translatesAutoresizingMaskIntoConstraints = false
        chatViewBottomConstraint = chatView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        guard let chatViewBottomConstraint = chatViewBottomConstraint else {
            fatalError("chatViewBottomConstraint가 초기화되지 않았습니다.")
        }
        
        NSLayoutConstraint.activate([
            chatView.topAnchor.constraint(equalTo: view.topAnchor),
            chatViewBottomConstraint,
            chatView.leftAnchor.constraint(equalTo: view.leftAnchor),
            chatView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            guard let chatViewBottomConstraint = chatViewBottomConstraint else {
                fatalError("chatViewBottomConstraint가 초기화되지 않았습니다.")
            }
            
            chatViewBottomConstraint.constant = -keyboardHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let chatViewBottomConstraint = chatViewBottomConstraint else {
            fatalError("chatViewBottomConstraint가 초기화되지 않았습니다.")
        }
        
        chatViewBottomConstraint.constant = -40
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
