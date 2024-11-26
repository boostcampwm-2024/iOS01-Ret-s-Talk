//
//  ChattingViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import Combine
import SwiftUI
import UIKit

final class ChattingViewController: UIViewController {
    private let messageManager: RetrospectChatManageable
    
    private var subscriptionSet: Set<AnyCancellable>
    private let retrospectSubject: CurrentValueSubject<Retrospect, Never>
    private let errorSubject: CurrentValueSubject<Error?, Never>
    
    private let chatView: ChatView
    
    // MARK: Initialization
    
    init(messageManager: RetrospectChatManageable) {
        self.messageManager = messageManager
        
        subscriptionSet = []
        retrospectSubject = CurrentValueSubject(Retrospect(userID: UUID()))
        errorSubject = CurrentValueSubject(nil)
        
        chatView = ChatView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ViewController lifecycle
    
    override func loadView() {
        view = chatView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatView.setTableViewDelegate(self)
        chatView.delegate = self
      
        setUpNavigationBar()
        addTapGestureOfDismissingKeyboard()
        addKeyboardObservers()
        
        Task {
            await messageManager.fetchPreviousMessages()
            retrospectSubject.send(await messageManager.retrospect)
        }

        observeMessages()
    }
    
    // MARK: Custom method

    private func addTapGestureOfDismissingKeyboard() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setUpNavigationBar() {
        title = "2024년 11월 29일" // 모델 연결 전 임시 하드코딩
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemImage: .leftChevron),
            style: .plain,
            target: self,
            action: #selector(backwardButtonTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Texts.rightBarButtonTitle,
            style: .plain,
            target: self,
            action: #selector(endChattingButtonTapped)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .blazingOrange
        navigationItem.rightBarButtonItem?.tintColor = .blazingOrange
    }
    
    private func addKeyboardObservers() {
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            chatView.updateBottomConstraintForKeyboard(height: keyboardHeight)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        chatView.updateBottomConstraintForKeyboard(height: 40)
    }

    private func observeMessages() {
        var previousMessageCount = retrospectSubject.value.chat.count

        retrospectSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] newMessages in
                guard let self = self else { return }

                let oldCount = previousMessageCount
                let newCount = newMessages.chat.count
                previousMessageCount = newCount
                guard oldCount < newCount else { return }

                let newIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                chatView.insertMessages(at: newIndexPaths)
            }
            .store(in: &subscriptionSet)
    }

    @objc private func backwardButtonTapped() {
        // navigationController: pop 작업
    }
    
    @objc private func endChattingButtonTapped() {
        // 대화끝내기 alert 작업
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource conformance

extension ChattingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        retrospectSubject.value.chat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = retrospectSubject.value.chat[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.contentConfiguration = UIHostingConfiguration {
            MessageCell(message: message.content, isUser: message.role == .user)
        }
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - ChatViewDelegate

extension ChattingViewController: ChatViewDelegate {
    func sendMessage(_ chatView: ChatView, with text: String) {
        Task {
            await messageManager.sendMessage(text)
            retrospectSubject.send(await messageManager.retrospect)
            
            chatView.updateRequestInProgressState(false)
        }
    }
}

// MARK: - Constants

private extension ChattingViewController {
    enum Texts {
        static let leftBarButtonImageName = "chevron.left"
        static let rightBarButtonTitle = "끝내기"
    }
}
