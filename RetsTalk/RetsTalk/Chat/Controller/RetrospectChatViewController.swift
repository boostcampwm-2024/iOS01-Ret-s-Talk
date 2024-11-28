//
//  RetrospectChatViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import Combine
import SwiftUI
import UIKit

final class RetrospectChatViewController: UIViewController {
    private let retrospectChatManager: RetrospectChatManageable
    
    private let renderingSubject: CurrentValueSubject<(retrospect: Retrospect, scrollToBottomNeeded: Bool), Never>
    private let errorSubject: CurrentValueSubject<Error?, Never>
    private let chatPrependingSubject: PassthroughSubject<ScrollInfo, Never>
    private var subscriptionSet: Set<AnyCancellable>
    
    private var isChatPrependable: Bool
    private var isChatViewDragging: Bool
    private var previousRetrospect: Retrospect?
    
    // MARK: View
    
    private let chatView: ChatView
    
    // MARK: Initialization
    
    init(retrospect: Retrospect, retrospectChatManager: RetrospectChatManageable) {
        self.retrospectChatManager = retrospectChatManager
        
        renderingSubject = CurrentValueSubject((retrospect, true))
        errorSubject = CurrentValueSubject(nil)
        chatPrependingSubject = PassthroughSubject<ScrollInfo, Never>()
        subscriptionSet = []
        
        isChatPrependable = true
        isChatViewDragging = false
        
        chatView = ChatView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Computed property
    
    private var retrospect: Retrospect {
        renderingSubject.value.retrospect
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

        subscribeChatEvents()
        
        fetchPreviousChat(isInitial: true)
    }
    
    // MARK: Tap gesture

    private func addTapGestureOfDismissingKeyboard() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: Navigation bar
    
    private func setUpNavigationBar() {
        title = retrospect.createdAt.formattedToKoreanStyle
        
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
    
    // MARK: Keyboard control
    
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
    
    @objc private func dismissKeyboard() {
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
    
    // MARK: Subscription

    private func subscribeChatEvents() {
        renderingSubject
            .sink(receiveValue: { [weak self] (retrospect, scrollToBottomNeeded) in
                self?.updateDataSourceDiffrence(from: self?.previousRetrospect?.chat ?? [], to: retrospect.chat)
                self?.previousRetrospect = retrospect
                if scrollToBottomNeeded {
                    self?.chatView.scrollToBottom()
                }
            })
            .store(in: &subscriptionSet)
        
        chatPrependingSubject
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.fetchPreviousChat(isInitial: false)
            }
            .store(in: &subscriptionSet)
    }
    
    // MARK: Message manager action
    
    private func fetchPreviousChat(isInitial: Bool) {
        guard isInitial || isChatPrependable else { return }
        
        Task { [weak self] in
            await self?.retrospectChatManager.fetchPreviousMessages()
            if let updatedRetrospect = await self?.retrospectChatManager.retrospect {
                self?.renderingSubject.send((updatedRetrospect, isInitial))
            }
        }
    }
    
    // MARK: Button actions

    @objc private func backwardButtonTapped() {}
    
    @objc private func endChattingButtonTapped() {}
    
    // MARK: DataSource diffrence managing
    
    private func updateDataSourceDiffrence(from source: [Message], to updated: [Message]) {
        var newIndexPaths = [IndexPath]()
        for (index, message) in updated.enumerated() where !source.contains(message) {
            newIndexPaths.append(IndexPath(row: index, section: 0))
        }
        chatView.insertMessages(at: newIndexPaths)
        isChatPrependable = newIndexPaths.isNotEmpty
    }
}

// MARK: - UITableViewDataSource conformance

extension RetrospectChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        retrospect.chat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = retrospect.chat[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.contentConfiguration = UIHostingConfiguration {
            MessageCell(message: message.content, isUser: message.role == .user)
        }
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - UITableViewDelegate conformance

extension RetrospectChatViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < scrollView.contentSize.height * Numerics.prependingRatio {
            if isChatPrependable && !isChatViewDragging {
                scrollView.contentOffset.y = max(Numerics.maxOffsetWhilePrepending, scrollView.contentOffset.y)
            }
            chatPrependingSubject.send(
                ScrollInfo(isDragging: isChatViewDragging, contentHeight: scrollView.contentSize.height)
            )
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isChatViewDragging = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isChatViewDragging = false
    }
}

// MARK: - ChatViewDelegate conformance

extension RetrospectChatViewController: ChatViewDelegate {
    func sendMessage(_ chatView: ChatView, with text: String) {
        Task {
            await retrospectChatManager.sendMessage(text)
            renderingSubject.send((await retrospectChatManager.retrospect, true))
            chatView.updateRequestInProgressState(false)
        }
    }
}

// MARK: - Prepend supporting type

fileprivate extension RetrospectChatViewController {
    struct ScrollInfo: Equatable {
        let isDragging: Bool
        let contentHeight: CGFloat
        let time: Date
        
        init(isDragging: Bool, contentHeight: CGFloat, time: Date = Date()) {
            self.isDragging = isDragging
            self.contentHeight = contentHeight
            self.time = time
        }
        
        static func == (lhs: ScrollInfo, rhs: ScrollInfo) -> Bool {
            let isDragging = lhs.isDragging || rhs.isDragging
            let isContentHeightDiffInsignificant = abs(lhs.contentHeight - rhs.contentHeight) / 100 < 0
            let isTimeDiffInsignificant = abs(lhs.time.timeIntervalSince(rhs.time)) < 0.1
            return isDragging || isContentHeightDiffInsignificant || isTimeDiffInsignificant
        }
    }
}

// MARK: - Constants

fileprivate extension RetrospectChatViewController {
    enum Numerics {
        static let prependingRatio = 0.2
        static let maxOffsetWhilePrepending = 1.0
    }
    
    enum Texts {
        static let leftBarButtonImageName = "chevron.left"
        static let rightBarButtonTitle = "끝내기"
    }
}
