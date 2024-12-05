//
//  RetrospectView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import UIKit

final class RetrospectListView: BaseView {
    
    // MARK: UI components
    
    let retrospectListTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .backgroundMain
        tableView.contentInset.bottom = Metrics.tableViewBottonPadding
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Texts.retrospectCellIdentifier)
        return tableView
    }()
    
    private let headerView: BaseView = {
        let view = BaseView()
        view.frame = CGRect(
            x: Metrics.headerViewX,
            y: Metrics.headerViewY,
            width: view.frame.width,
            height: Metrics.fixedButtonAreaHeight
        )
        return view
    }()
    
    private let calendarButton: RetrospectCountButton = {
        let button = RetrospectCountButton(
            imageSystemName: Texts.calendarButtonImageName,
            title: Texts.calendarButtonTitle,
            subtitle: ""
        )
        return button
    }()
    
    private let totalCountView: RetrospectCountButton = {
        let button = RetrospectCountButton(
            imageSystemName: Texts.totalCountButtonImageName,
            title: Texts.totalCountButtonTitle,
            subtitle: ""
        )
        button.setImageColor(.systemGray4)
        return button
    }()
    
    private let createRetrospectButton = CreateRetrospectButton()
    
    // MARK: RetsTalk lifecycle

    override func setupStyles() {
        super.setupStyles()
        
        backgroundColor = .backgroundMain
        totalCountView.setSubtitleLabelColor(.systemGray4)
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(retrospectListTableView)
        addSubview(createRetrospectButton)

        retrospectListTableView.tableHeaderView = headerView
        headerView.addSubview(calendarButton)
        headerView.addSubview(totalCountView)
    }
    
    override func setupSubviewLayouts() {
        super.setupSubviewLayouts()
        
        setupTableViewLayout()
        setupCreateButtonLayout()
        setupHeaderViewLayout()
    }
    
    private func setupTableViewLayout() {
        retrospectListTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            retrospectListTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            retrospectListTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            retrospectListTableView.leftAnchor.constraint(equalTo: leftAnchor),
            retrospectListTableView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
    
    private func setupCreateButtonLayout() {
        createRetrospectButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createRetrospectButton.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: Metrics.buttonBottomAnchor
            ),
            createRetrospectButton.centerXAnchor.constraint(
                equalTo: centerXAnchor
            ),
            createRetrospectButton.widthAnchor.constraint(
                equalToConstant: Metrics.diameter
            ),
            createRetrospectButton.heightAnchor.constraint(
                equalToConstant: Metrics.diameter
            ),
        ])
    }
    
    private func setupHeaderViewLayout() {
        calendarButton.translatesAutoresizingMaskIntoConstraints = false
        totalCountView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            calendarButton.topAnchor.constraint(
                equalTo: headerView.topAnchor
            ),
            calendarButton.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: Metrics.calendarButtonMargin
            ),

            totalCountView.topAnchor.constraint(
                equalTo: headerView.topAnchor
            ),
            totalCountView.leadingAnchor.constraint(
                equalTo: headerView.centerXAnchor,
                constant: Metrics.totalCountButtonMargin
            ),
        ])
        
        sendSubviewToBack(retrospectListTableView)
        bringSubviewToFront(createRetrospectButton)
    }

    // MARK: Custom Method

    func setTableViewDelegate(_ delegate: UITableViewDelegate) {
        retrospectListTableView.delegate = delegate
    }
    
    func addCreateButtonAction(_ action: UIAction) {
        createRetrospectButton.addAction(action, for: .touchUpInside)
    }
    
    func addCalendarButtonAction(_ action: UIAction) {
        calendarButton.addAction(action, for: .touchUpInside)
    }
    
    func updateHeaderContent(totalCount: Int, monthlyCount: Int) {
        totalCountView.setSubtitle("\(totalCount)개")
        calendarButton.setSubtitle("\(monthlyCount)개")
    }

}

// MARK: - Constants

private extension RetrospectListView {
    enum Metrics {
        static let tableViewBottonPadding = 60.0
        static let diameter = 80.0
        static let buttonBottomAnchor = -10.0
        static let fixedButtonAreaHeight = 40.0
        static let calendarButtonMargin = 16.0
        static let totalCountButtonMargin = 32.0
        
        static let headerViewX = 0.0
        static let headerViewY = 0.0
    }
    
    enum Texts {
        static let foregroundImageName = "plus"
        
        static let calendarButtonImageName = "calendar"
        static let calendarButtonTitle = "이달의 회고"
        
        static let totalCountButtonImageName = "tray.full.fill"
        static let totalCountButtonTitle = "총 회고 수"
    }
}
