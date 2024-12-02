//
//  RetrospectChatViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import Combine
import SwiftUI
import UIKit

final class RetrospectChatViewController: BaseKeyBoardViewController {
    private let retrospectChatManager: RetrospectChatManageable
    
    private let renderingSubject: CurrentValueSubject<(retrospect: Retrospect, scrollToBottomNeeded: Bool), Never>
    private let errorSubject: CurrentValueSubject<Error?, Never>
    private let chatPrependingSubject: PassthroughSubject<ScrollInfo, Never>
    
    private var isChatPrependable: Bool
    private var isChatViewDragging: Bool
    private var previousRetrospect: Retrospect?
    
    // MARK: View
    
    private let chatView = ChatView()
    
    // MARK: Initialization
    
    init(retrospect: Retrospect, retrospectChatManager: RetrospectChatManageable) {
        self.retrospectChatManager = retrospectChatManager
        
        renderingSubject = CurrentValueSubject((retrospect, true))
        errorSubject = CurrentValueSubject(nil)
        chatPrependingSubject = PassthroughSubject<ScrollInfo, Never>()
        
        isChatPrependable = true
        isChatViewDragging = false
        
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
        
        addTapGestureOfDismissingKeyboard()
        fetchPreviousChat(isInitial: true)
    }
    
    // MARK: RetsTalk lifecycle
    
    override func setupDelegation() {
        super.setupDelegation()
        
        chatView.setTableViewDelegate(self)
        chatView.delegate = self
    }

    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        title = retrospect.createdAt.formattedToKoreanStyle
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Texts.endChattingButtonTitle,
            style: .plain,
            target: self,
            action: #selector(endChattingButtonTapped)
        )
    }
    
    override func setupSubscription(on subscriptionSet: inout Set<AnyCancellable>) {
        super.setupSubscription(on: &subscriptionSet)
        
        renderingSubject
            .sink(receiveValue: { [weak self] (retrospect, scrollToBottomNeeded) in
                self?.updateDataSourceDifference(from: self?.previousRetrospect?.chat ?? [], to: retrospect.chat)
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
    
    // MARK: Keyboard control
    
    override func handleKeyboardWillShowEvent(using keyboardInfo: KeyboardInfo) {
        super.handleKeyboardWillShowEvent(using: keyboardInfo)
        
        chatView.updateLayoutForKeyboard(using: keyboardInfo)
    }
    
    override func handleKeyboardWillHideEvent(using keyboardInfo: KeyboardInfo) {
        super.handleKeyboardWillHideEvent(using: keyboardInfo)
        
        chatView.updateLayoutForKeyboard(using: keyboardInfo)
    }
    
    private func addTapGestureOfDismissingKeyboard() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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

    @objc private func endChattingButtonTapped() {
        Task { [weak self] in
            await self?.retrospectChatManager.endRetrospect()
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource conformance

extension RetrospectChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        retrospect.chat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = retrospect.chat[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Texts.messageCellIdentifier, for: indexPath)
        cell.contentConfiguration = UIHostingConfiguration {
            MessageCell(message: message.content, isUser: message.role == .user)
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    // MARK: DataSource difference managing
    
    private func updateDataSourceDifference(from source: [Message], to updated: [Message]) {
        var newIndexPaths = [IndexPath]()
        for (index, message) in updated.enumerated() where !source.contains(message) {
            newIndexPaths.append(IndexPath(row: index, section: 0))
        }
        chatView.insertMessages(at: newIndexPaths)
        isChatPrependable = newIndexPaths.isNotEmpty
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
        static let endChattingButtonTitle = "끝내기"
    }
}
