//
//  ChattingViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit
import SwiftUI
import Combine

final class ChattingViewController: AlertPresentableViewController {
    private let chatView = ChatView()
    private nonisolated let messageManager: MessageManageable
    private var retrospect: Retrospect { messageManager.retrospectSubject.value }
    private var messageManagerListener: MessageManagerListener { messageManager.messageManagerListener }
    private var cancellables: Set<AnyCancellable> = []

    init(messageManager: MessageManageable) {
        self.messageManager = messageManager

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ViewController lifecycle method
    
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

        initialMessageFetch()
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            try await messageManager.send(
                Message(
                    retrospectID: retrospect.id,
                    role: .user,
                    content: "",
                    createdAt: Date()
                )
            )
        }
    }
    
    // MARK: custom method

    private func addTapGestureOfDismissingKeyboard() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setUpNavigationBar() {
        title = "2024년 11월 19일" // 모델 연결 전 임시 하드코딩
        
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
        var previousMessageCount = retrospect.chat.count

        messageManager.retrospectSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] newRetrospect in
                guard let self = self else { return }

                let oldCount = previousMessageCount
                let newCount = newRetrospect.chat.filter({ !$0.content.isEmpty }).count
                previousMessageCount = newCount
                guard oldCount < newCount else { return }

                let newIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                chatView.insertMessages(at: newIndexPaths)
                chatView.scrollToBottom()
            }
            .store(in: &cancellables)
    }

    @objc private func backwardButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func endChattingButtonTapped() {
        // 대화끝내기 alert 작업
        let actions: [UIAlertAction] = [
            UIAlertAction(
                title: Texts.cancel,
                style: .default,
                handler: { _ in print("취소됨") }
            ),
            UIAlertAction(
                title: Texts.end,
                style: .destructive,
                handler: { [weak self] _ in
                    print("끝냄")
                    self?.messageManager.endRetrospect()
                    self?.navigationController?.popViewController(animated: true)
                }
            ),
        ]
        presentAlert(for: .end, actions: actions)
    }

    private func initialMessageFetch() {
        Task {
            do {
                try await messageManager.fetchMessages(offset: Numeric.initialOffset, amount: Numeric.amount)
                switch retrospect.status {
                case .finished:
                    chatView.scrollToTop()
                case .inProgress:
                    chatView.scrollToBottom()
                }
            } catch {
                
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource conformance

extension ChattingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        retrospect.chat.filter({ !$0.content.isEmpty }).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = retrospect.chat.filter({ !$0.content.isEmpty })[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.contentConfiguration = UIHostingConfiguration {
            MessageCell(message: message.content, isUser: message.role == .user)
        }
        .margins(.vertical, Numeric.verticalCellMargin)
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - ChatViewDelegate

extension ChattingViewController: ChatViewDelegate {
    func sendMessage(_ chatView: ChatView, with text: String) {
        let userMessage = Message(retrospectID: retrospect.id, role: .user, content: text, createdAt: Date())

        Task {
            do {
                try await messageManager.send(userMessage)

                chatView.updateRequestInProgressState(false)
            } catch {
                print("response error")
            }
        }
    }
}

// MARK: - Constants

private extension ChattingViewController {
    enum Numeric {
        static let initialOffset = 0
        static let amount = 20
        static let verticalCellMargin = 4.0
    }

    enum Texts {
        static let leftBarButtonImageName = "chevron.left"
        static let rightBarButtonTitle = "끝내기"
        static let cancel = "취소"
        static let end = "대화 끝내기"
    }
}
