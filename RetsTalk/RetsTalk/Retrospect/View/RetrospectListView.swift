//
//  RetrospectView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import UIKit

final class RetrospectListView: UIView {
    
    // MARK: UI components

    private let retrospectListTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .backgroundMain
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.retrospectCellIdentifier)
        return tableView
    }()
    
    private let createRetrospectButton: CreateRetrospectButton = {
        let button = CreateRetrospectButton()
        button.frame.size = .init(width: 80, height: 80)
        return button
    }()
    
    // MARK: Init method

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpTableViewLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpTableViewLayout()
    }
    
    // MARK: Custom Method
    
    private func setUpTableViewLayout() {
        addSubview(retrospectListTableView)
        retrospectListTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            retrospectListTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            retrospectListTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            retrospectListTableView.leftAnchor.constraint(equalTo: leftAnchor),
            retrospectListTableView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
    
    private func setUpButtonLayout() {
        addSubview(createRetrospectButton)
        createRetrospectButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            createRetrospectButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            createRetrospectButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            createRetrospectButton.widthAnchor.constraint(equalToConstant: 80),
            createRetrospectButton.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    func setTableViewDelegate(_ delegate: UITableViewDelegate & UITableViewDataSource) {
        retrospectListTableView.delegate = delegate
        retrospectListTableView.dataSource = delegate
    }
}
