//
//  CreateRetrospectButton.swift
//  RetsTalk
//
//  Created by HanSeung on 11/21/24.
//

import UIKit

final class CreateRetrospectButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2
        guard let imageView = imageView else { return }
        
        let imageSize = bounds.width * Metrics.imageScale
        imageView.frame.size = CGSize(width: imageSize, height: imageSize)
        imageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupStyle()
    }
    
    private func setupStyle() {
        backgroundColor = .blazingOrange
        tintColor = .white
        setImage(UIImage(systemName: Texts.foregroundImageName), for: .normal)
        clipsToBounds = true
    }
}

// MARK: - Constants

private extension CreateRetrospectButton {
    enum Metrics {
        static let imageScale = 0.4
    }
    
    enum Texts {
        static let foregroundImageName = "plus"
    }
}
