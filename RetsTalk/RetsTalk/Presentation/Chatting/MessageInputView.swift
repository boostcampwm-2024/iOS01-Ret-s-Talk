//
//  MessageInputView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit

protocol MessageInputViewDelegate: AnyObject {
    func updateMessageInputViewHeight(to height: CGFloat)
}

final class MessageInputView: UIView {
    var delegate: MessageInputViewDelegate?
    
    // MARK: Constants
    
    private enum Metrics {
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
    
    private enum Texts {
        static let sendButtonIconName = "arrow.up.circle"
        static let textInputPlaceholder = "메시지 입력"
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
        return button
    }()
    
    // MARK: init
    
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
    
    // MARK: custom method
    
    private func setUpActions() {
        sendButton.addAction(UIAction(handler: { _ in
            self.textInputView.resignFirstResponder()
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
}

extension MessageInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let contentSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        let inputViewHeight = contentSize.height + 2 * Metrics.textViewVerticalMargin
        let backgroundVerticalMargin = 2 * Metrics.backgroundVerticalMargin
        
        if inputViewHeight <= Metrics.textViewMaxHeight {
            textView.isScrollEnabled = false
            delegate?.updateMessageInputViewHeight(to: max(
                Metrics.backgroundHeight + backgroundVerticalMargin,
                inputViewHeight + backgroundVerticalMargin
            ))
        } else {
            textView.isScrollEnabled = true
            delegate?.updateMessageInputViewHeight(to: Metrics.textViewMaxHeight + backgroundVerticalMargin)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.textColor = .black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = .placeholderText
            textView.text = Texts.textInputPlaceholder
        }
    }
}
