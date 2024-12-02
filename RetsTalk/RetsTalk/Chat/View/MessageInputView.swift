//
//  MessageInputView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit

@MainActor
protocol MessageInputViewDelegate: AnyObject {
    func updateMessageInputViewHeight(_ messageInputView: MessageInputView, to height: CGFloat)
    func sendMessage(_ messageInputView: MessageInputView, with text: String)
}

final class MessageInputView: BaseView {
    private var isRequestInProgress = false {
        didSet { updateSendButtonState() }
    }
    private var isPlaceholderDeactivated = false
    
    // MARK: Subviews
    
    private var backgroundView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = Metrics.backgroundCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var textInputView: UITextView = {
        let textView = UITextView()
        textView.font = .appFont(.body)
        textView.textColor = .placeholderText
        textView.text = Texts.textInputPlaceholder
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private var sendButton: UIButton = {
        let button = UIButton()
        let icon = UIImage(
            systemName: Texts.sendButtonIconName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: Metrics.sendButtonSideLength, weight: .light)
        )
        button.setImage(icon, for: .normal)
        button.tintColor = .blazingOrange
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: RetsTalk lifecycle
    
    override func setupStyles() {
        super.setupStyles()
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(backgroundView)
        backgroundView.addSubview(textInputView)
        backgroundView.addSubview(sendButton)
        
        textInputView.delegate = self
    }
    
    override func setupSubviewLayouts() {
        super.setupSubviewLayouts()
        
        setUpBackgroundViewLayout()
        setUpSendButtonLayout()
        setUpTextInputViewLayout()
    }
    
    override func setupActions() {
        super.setupActions()
        
        sendButton.addAction(
            UIAction(
                handler: { [weak self] _ in
                    guard let self else { return }
                    
                    self.delegate?.sendMessage(self, with: self.textInputView.text)
                    self.textInputView.text = nil
                    self.sendButton.isEnabled = false
                    self.updateRequestInProgressState(true)
                    self.updateHeight(to: self.currentTextViewHeight(textView: textInputView))
                }),
            for: .touchUpInside
        )
    }
    
    // MARK: Delegate
    
    weak var delegate: MessageInputViewDelegate?
    
    // MARK: State change handling
    
    private func updateSendButtonState() {
        sendButton.isEnabled = !isRequestInProgress && textInputView.text.isNotEmpty && isPlaceholderDeactivated
    }
    
    private func updateSendButtonState(isEnabled: Bool) {
        sendButton.isEnabled = isEnabled
    }
    
    private func currentTextViewHeight(textView: UITextView) -> Double {
        let contentSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        let inputViewHeight = contentSize.height + 2 * Metrics.textViewVerticalMargin
        return max(inputViewHeight, Metrics.backgroundHeight)
    }
    
    func updateRequestInProgressState(_ state: Bool) {
        isRequestInProgress = state
    }
}

// MARK: - UITextViewDelegate

extension MessageInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let inputViewHeight = currentTextViewHeight(textView: textView)
        
        textView.isScrollEnabled = inputViewHeight > Metrics.textViewMaxHeight
        if textView.isScrollEnabled {
            updateHeight(to: Metrics.textViewMaxHeight)
        } else {
            updateHeight(to: inputViewHeight)
        }
        updateSendButtonState()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .placeholderText else { return }
        
        textView.text = nil
        textView.textColor = .label
        isPlaceholderDeactivated = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard (textView.text ?? "").isEmpty else { return }
        
        textView.text = Texts.textInputPlaceholder
        textView.textColor = .placeholderText
        isPlaceholderDeactivated = false
    }
    
    private func updateHeight(to value: CGFloat) {
        delegate?.updateMessageInputViewHeight(self, to: value + 2 * Metrics.backgroundVerticalMargin)
    }
}

// MARK: - Subviews layouts

fileprivate extension MessageInputView {
    private func setUpBackgroundViewLayout() {
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(
                equalTo: leftAnchor,
                constant: Metrics.backgroundHorizontalMargin
            ),
            backgroundView.rightAnchor.constraint(
                equalTo: rightAnchor,
                constant: -Metrics.backgroundHorizontalMargin
            ),
            backgroundView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Metrics.backgroundVerticalMargin
            ),
            backgroundView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Metrics.backgroundVerticalMargin),
        ])
    }
    
    private func setUpSendButtonLayout() {
        NSLayoutConstraint.activate([
            sendButton.heightAnchor.constraint(
                equalToConstant: Metrics.sendButtonSideLength
            ),
            sendButton.widthAnchor.constraint(
                equalToConstant: Metrics.sendButtonSideLength
            ),
            sendButton.topAnchor.constraint(
                equalTo: backgroundView.topAnchor,
                constant: Metrics.sendButtonMargin
            ),
            sendButton.trailingAnchor.constraint(
                equalTo: backgroundView.trailingAnchor,
                constant: -Metrics.sendButtonMargin
            ),
        ])
    }
    
    private func setUpTextInputViewLayout() {
        NSLayoutConstraint.activate([
            textInputView.topAnchor.constraint(
                equalTo: backgroundView.topAnchor,
                constant: Metrics.textViewVerticalMargin
            ),
            textInputView.bottomAnchor.constraint(
                equalTo: backgroundView.bottomAnchor,
                constant: -Metrics.textViewVerticalMargin
            ),
            textInputView.leadingAnchor.constraint(
                equalTo: backgroundView.leadingAnchor,
                constant: Metrics.textViewHorizontalMargin
            ),
            textInputView.trailingAnchor.constraint(
                equalTo: sendButton.leadingAnchor,
                constant: -Metrics.sendButtonMargin
            ),
        ])
    }
}

// MARK: - Constants

private extension MessageInputView {
    enum Metrics {
        static let backgroundHeight = 40.0
        static let backgroundCornerRadius = 20.0
        static let backgroundVerticalMargin = 7.0
        static let backgroundHorizontalMargin = 16.0

        static let sendButtonSideLength = 28.0
        static let sendButtonMargin = 6.0

        static let textViewVerticalMargin = 10.0
        static let textViewHorizontalMargin = 10.0
        static let textViewMaxHeight = 100.0
    }

    enum Texts {
        static let sendButtonIconName = "arrow.up.circle"
        static let textInputPlaceholder = "메시지 입력"
    }
}
