//
//  RetryView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/18/24.
//

import UIKit

final class RetryView: BaseView {
    
    // MARK: Subviews

    private let backgroundLabel: UILabel = {
        let label = UILabel()
        label.text = Texts.backgroundLabelText
        label.textColor = .blazingOrange
        label.font = UIFont.appFont(.body)
        return label
    }()
    
    let retryButton: UIButton = {
        let button = UIButton()
        button.setTitle(Texts.buttonLabelText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blazingOrange
        button.layer.cornerRadius = Metrics.cornerRadius
        return button
    }()
    
    // MARK: RetsTalk lifecycle
    
    override func setupStyles() {
        super.setupStyles()
        
        backgroundColor = .backgroundRetrospect
        layer.borderWidth = Metrics.backgroundBorderWidth
        layer.borderColor = UIColor.blazingOrange.cgColor
        layer.cornerRadius = Metrics.cornerRadius
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(retryButton)
        addSubview(backgroundLabel)
    }
    
    override func setupSubviewLayouts() {
        super.setupSubviewLayouts()
        
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            retryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.padding),
            retryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.padding),
            retryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.padding),
            retryButton.heightAnchor.constraint(equalToConstant: Metrics.buttonHeight),
            
            backgroundLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.padding),
            backgroundLabel.bottomAnchor.constraint(equalTo: retryButton.topAnchor, constant: -Metrics.padding),
            
            heightAnchor.constraint(equalToConstant: Metrics.retryViewHeight),
        ])
    }
    
    // MARK: Setup action
    
    func addAction(_ action: @escaping () -> Void) {
        retryButton.addAction(
            UIAction { _ in action() },
            for: .touchUpInside
        )
    }
}

// MARK: - Constants

private extension RetryView {
    enum Metrics {
        static let cornerRadius = 16.0
        static let backgroundBorderWidth = 0.5
        static let backgroundLabelHeight = 36.0
        static let padding = 10.0
        static let buttonHeight = 44.0
        static let retryViewHeight = 92.0
    }
    
    enum Texts {
        static let buttonLabelText = "다시 시도"
        static let backgroundLabelText = "인터넷 연결상태가 좋지 않습니다."
    }
}
