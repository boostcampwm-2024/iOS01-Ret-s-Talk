//
//  RetrospectCountButton.swift
//  RetsTalk
//
//  Created by HanSeung on 12/1/24.
//

import UIKit

class RetrospectCountButton: UIButton {
    
    // MARK: UI Components
    
    private let iconImageView = UIImageView()
    private let textStackView = UIStackView()
    private let buttonTitleLabel = UILabel()
    private let buttonSubtitleLabel = UILabel()
    
    // MARK: Init method
    
    init(imageSystemName: String, title: String, subtitle: String) {
        super.init(frame: .zero)
        setupStyle(imageSystemName: imageSystemName, title: title, subtitle: subtitle)
        addSubview()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageColor(_ color: UIColor) {
        iconImageView.tintColor = color
    }
    
    // MARK: Setup Method
    
    private func setupStyle(imageSystemName: String, title: String, subtitle: String) {
        iconImageView.image = UIImage(systemName: imageSystemName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .blazingOrange
        
        buttonTitleLabel.text = title
        buttonTitleLabel.font = UIFont.appFont(.body)
        buttonTitleLabel.textColor = .secondaryLabel
        
        buttonSubtitleLabel.text = subtitle
        buttonSubtitleLabel.font = UIFont.appFont(.subtitle)
        buttonSubtitleLabel.textColor = .black
        
        textStackView.axis = .vertical
        textStackView.alignment = .leading
        
        self.backgroundColor = .clear
        self.clipsToBounds = true
    }
    
    private func addSubview() {
        addSubview(iconImageView)
        addSubview(textStackView)
        textStackView.addArrangedSubview(buttonTitleLabel)
        textStackView.addArrangedSubview(buttonSubtitleLabel)
    }
    
    private func setupConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Metrics.iconImageHeight),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),

            textStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Metrics.spacing),
            textStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
        self.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}

private extension RetrospectCountButton {
    enum Metrics {
        static let iconImageHeight = 40.0
        static let spacing = 4.0
    }
}
