//
//  RetrospectCalendarTableView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 12/1/24.
//

import UIKit

final class RetrospectCalendarTableView: BaseView {
    let retrospectListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Texts.retrospectCellIdentifier)
        return tableView
    }()
    
    // MARK: RetsTalk lifecycle
    
    override func setupStyles() {
        super.setupStyles()
        
        backgroundColor = .backgroundMain
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(retrospectListTableView)
    }
    
    override func setupSubviewLayouts() {
        super.setupSubviewLayouts()
        
        setupRetrospectCalendarTableViewLayouts()
    }
    
    func setupretrospectListTableViewDelegate(_ delegate: UITableViewDelegate) {
        retrospectListTableView.delegate = delegate
    }
}

// MARK: - Subviews layouts

fileprivate extension RetrospectCalendarTableView {
    func setupRetrospectCalendarTableViewLayouts() {
        NSLayoutConstraint.activate([
            retrospectListTableView.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.topPadding),
            retrospectListTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            retrospectListTableView.leftAnchor.constraint(equalTo: leftAnchor),
            retrospectListTableView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
}

// MARK: - Constants

private extension RetrospectCalendarTableView {
    enum Metrics {
        static let topPadding = 16.0
    }
}
