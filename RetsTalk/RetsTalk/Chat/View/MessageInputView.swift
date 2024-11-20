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

@MainActor
final class MessageInputView: UIView {
    weak var delegate: MessageInputViewDelegate?
    private var isRequestInProgress = false {
        didSet {
            if textInputView.text.isNotEmpty { updateSendButtonState(isEnabled: !isRequestInProgress) }
        }
    }

    // MARK: UI Components
    
    private var backgroundView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = Metrics.backgroundCornerRadius
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
        return textView
    }()
    
    private var sendButton: UIButton = {
        let button = UIButton()
        let icon = UIImage(
            systemName: Texts.sendButtonIconName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: Metrics.sendButtonSideLength, weight: .light)
        )
        button.setImage(icon, for: .normal)
        button.tintColor = UIColor.appColor(.blazingOrange)
        button.isEnabled = false
        return button
    }()
    
    // MARK: Init

    init() {
        super.init(frame: .zero)
        
        setUpLayout()
        setUpActions()
        textInputView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpLayout()
        setUpActions()
        textInputView.delegate = self
    }
    
    // MARK: Custom method

    private func setUpActions() {
        sendButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.delegate?.sendMessage(self, with: self.textInputView.text)
            self.textInputView.text = nil
            self.sendButton.isEnabled = false
            self.updateRequestInProgressState(true)
        }), for: .touchUpInside)
    }
    
    private func setUpLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        setUpBackgroundViewLayout()
        setUpSendButtonLayout()
        setUpTextInputViewLayout()
    }
    
    private func setUpBackgroundViewLayout() {
        self.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundView.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundView.addSubview(textInputView)
        textInputView.translatesAutoresizingMaskIntoConstraints = false
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

    func updateSendButtonState(isEnabled: Bool) {
    private func updateSendButtonState(isEnabled: Bool) {
        sendButton.isEnabled = isEnabled
    }

    func updateRequestInProgressState(_ state: Bool) {
        isRequestInProgress = state
    }
}

// MARK: - UITextViewDelegate

extension MessageInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let contentSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        let inputViewHeight = contentSize.height + 2 * Metrics.textViewVerticalMargin

        textView.isScrollEnabled = inputViewHeight > Metrics.textViewMaxHeight
        if textView.isScrollEnabled {
            updateHeight(to: Metrics.textViewMaxHeight)
        } else {
            updateHeight(to: max(Metrics.backgroundHeight, inputViewHeight))
        }
        updateSendButtonState(
            isEnabled:
                textView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty ?? false
                &&
                !isRequestInProgress
        )
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .placeholderText else { return }
        
        textView.text = nil
        textView.textColor = .black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard (textView.text ?? "").isEmpty else { return }
        
        textView.text = Texts.textInputPlaceholder
        textView.textColor = .placeholderText
    }
    
    private func updateHeight(to value: CGFloat) {
        delegate?.updateMessageInputViewHeight(self, to: value + 2 * Metrics.backgroundVerticalMargin)
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
