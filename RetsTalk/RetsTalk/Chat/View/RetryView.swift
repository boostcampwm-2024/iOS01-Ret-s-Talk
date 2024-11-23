//
//  RetryView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/18/24.
//

import UIKit

final class RetryView: UIView {
    
    // MARK: UI Components

    private let backgroundLabel: UILabel = {
        let label = UILabel()
        label.text = Texts.backgroundLabelText
        label.textColor = .blazingOrange
        label.font = UIFont.appFont(.body)
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton()
        button.setTitle(Texts.buttonLabelText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blazingOrange
        button.layer.cornerRadius = Metrics.cornerRadius
        return button
    }()
    
    // MARK: init method

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureAppearance()
        setUpSubViewLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureAppearance()
        setUpSubViewLayout()
    }
    
    // MARK: custom method

    private func configureAppearance() {
        backgroundColor = .backgroundRetrospect
        layer.borderWidth = Metrics.backgroundBorderWidth
        layer.borderColor = UIColor.blazingOrange.cgColor
        layer.cornerRadius = Metrics.cornerRadius
    }
    
    private func setUpSubViewLayout() {
        addSubview(retryButton)
        addSubview(backgroundLabel)
        
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            retryButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Metrics.padding),
            retryButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Metrics.padding),
            retryButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Metrics.padding),
            retryButton.heightAnchor.constraint(equalToConstant: Metrics.buttonHeight),
            
            backgroundLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            backgroundLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: Metrics.padding),
            backgroundLabel.bottomAnchor.constraint(equalTo: retryButton.topAnchor, constant: -Metrics.padding),
            
            self.heightAnchor.constraint(equalToConstant: Metrics.retryViewHeight),
        ])
    }
    
    func addAction(_ action: @escaping () -> Void) {
        retryButton.addAction(UIAction(handler: { _ in
            action()
        }), for: .touchUpInside)
    }
}

// MARK: - constants

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
