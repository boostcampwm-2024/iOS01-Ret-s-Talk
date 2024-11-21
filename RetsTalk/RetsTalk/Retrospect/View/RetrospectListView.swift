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
    
    private let createRetrospectButton = CreateRetrospectButton()
    
    // MARK: Init method

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpTableViewLayout()
        setUpButtonLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpTableViewLayout()
        setUpButtonLayout()
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
            createRetrospectButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            createRetrospectButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            createRetrospectButton.widthAnchor.constraint(equalToConstant: Metrics.diameter),
            createRetrospectButton.heightAnchor.constraint(equalToConstant: Metrics.diameter),
        ])
        sendSubviewToBack(retrospectListTableView)

        bringSubviewToFront(createRetrospectButton)
    }
    
    func setTableViewDelegate(_ delegate: UITableViewDelegate & UITableViewDataSource) {
        retrospectListTableView.delegate = delegate
        retrospectListTableView.dataSource = delegate
    }
    
    func addCreateButtonAction(_ action: UIAction) {
        createRetrospectButton.addAction(action, for: .touchUpInside)
    }
}

// MARK: - Constants

private extension RetrospectListView {
    enum Metrics {
        static let diameter = 80.0
    }
    
    enum Texts {
        static let foregroundImageName = "plus"
    }
}
