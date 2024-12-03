//
//  SectionHeaderView.swift
//  RetsTalk
//
//  Created by HanSeung on 12/2/24.
//

import UIKit

final class SectionHeaderView: UIView {
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(.title)
        label.frame = CGRect(
            x: Metrics.titleLabelX,
            y: Metrics.titleLabelY,
            width: Metrics.titleLabelWidth,
            height: Metrics.titleLabelHeight
        )
        return label
    }()
    
    convenience init(title: String?) {
        self.init(frame: .zero)
        titleLabel.text = title
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(titleLabel)
        backgroundColor = .clear
    }
}

private extension SectionHeaderView {
    enum Metrics {
        static let titleLabelHeight = 40.0
        static let titleLabelWidth = 200.0
        
        static let titleLabelX = 16.0
        static let titleLabelY = 0.0
    }
}
