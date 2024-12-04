//
//  SectionHeaderView.swift
//  RetsTalk
//
//  Created by HanSeung on 12/2/24.
//

import UIKit

final class SectionHeaderView: BaseView {
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
    
    // MARK: Initialization

    init(title: String?) {
        super.init(frame: .zero)
        
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: RetsTalk lifecycle
    
    override func setupStyles() {
        super.setupStyles()
        
        backgroundColor = .backgroundMain
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(titleLabel)
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
