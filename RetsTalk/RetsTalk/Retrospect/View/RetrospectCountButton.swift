//
//  RetrospectCountButton.swift
//  RetsTalk
//
//  Created by HanSeung on 12/1/24.
//

import UIKit

class RetrospectCountButton: UIButton {
    
    // MARK: UI Components
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .blazingOrange
        return imageView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    private let buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.body)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let buttonSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.subtitle)
        label.textColor = .black
        return label
    }()
    
    // MARK: Init Method
    
    init(imageSystemName: String, title: String, subtitle: String? = nil) {
        super.init(frame: .zero)
        
        setupStyle(imageSystemName: imageSystemName, title: title, subtitle: subtitle)
        addSubview()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Style Setting Method

    func setImageColor(_ color: UIColor) {
        iconImageView.tintColor = color
    }
    
    func setSubtitle(_ title: String) {
        buttonSubtitleLabel.text = title
    }
    
    func setSubtitleLabelColor(_ color: UIColor) {
        buttonSubtitleLabel.textColor = color
    }
    
    // MARK: Setup Method
    
    private func setupStyle(imageSystemName: String, title: String, subtitle: String?) {
        backgroundColor = .clear
        clipsToBounds = true
        iconImageView.image = UIImage(systemName: imageSystemName)
        buttonTitleLabel.text = title
        buttonSubtitleLabel.text = subtitle
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
        
        iconImageView.isUserInteractionEnabled = false
        textStackView.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Metrics.iconImageWidth),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
            
            textStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Metrics.spacing),
            textStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
        heightAnchor.constraint(equalToConstant: Metrics.buttonHeight).isActive = true
    }
}

// MARK: - Constants

private extension RetrospectCountButton {
    enum Metrics {
        static let buttonHeight = 60.0
        static let iconImageWidth = 40.0
        static let spacing = 4.0
    }
}
