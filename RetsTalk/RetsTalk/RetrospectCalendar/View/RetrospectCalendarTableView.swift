//
//  RetrospectCalendarTableView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 12/1/24.
//

import UIKit

final class RetrospectCalendarTableView: UIView {
    let retrospectListTableView = UITableView()
    
    // MARK: Initalization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .backgroundMain
        retrospectListTableVewSetUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View SetUp
    
    private func retrospectListTableVewSetUp() {
        addSubview(retrospectListTableView)
        
        retrospectListTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            retrospectListTableView.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.topPadding),
            retrospectListTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            retrospectListTableView.leftAnchor.constraint(equalTo: leftAnchor),
            retrospectListTableView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
        
        retrospectListTableView.separatorStyle = .none
        retrospectListTableView.backgroundColor = .clear
        retrospectListTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Constants.Texts.retrospectCellIdentifier
        )
    }
}

// MARK: - Constants

extension RetrospectCalendarTableView {
    enum Metrics {
        static let topPadding = 16.0
    }
}
