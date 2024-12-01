//
//  RetrospectCalendarView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/30/24.
//

import UIKit

final class RetrospectCalendarView: UIView {
    private let calendarView = UICalendarView()
    let retrospectListTableView = UITableView()
    
    // MARK: Initalization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .backgroundMain
        calendarViewSetUp()
        retrospectListTableViewSetUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View SetUp
    
    private func calendarViewSetUp() {
        addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            calendarView.leftAnchor.constraint(equalTo: leftAnchor),
            calendarView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
        
        calendarView.wantsDateDecorations = true
        calendarView.fontDesign = .rounded
        calendarView.tintColor = .blazingOrange
    }
    
    private func retrospectListTableViewSetUp() {
        addSubview(retrospectListTableView)
        retrospectListTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            retrospectListTableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor),
            retrospectListTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            retrospectListTableView.leftAnchor.constraint(equalTo: leftAnchor),
            retrospectListTableView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
        
        retrospectListTableView.separatorStyle = .none
        retrospectListTableView.backgroundColor = .backgroundMain
        retrospectListTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Constants.retrospectCellIdentifier
        )
    }
    
    func reloadDecorations(forDateComponents dateCompoenents: [DateComponents]) {
        calendarView.reloadDecorations(forDateComponents: dateCompoenents, animated: true)
    }
    
    func setCalendarViewDelegate(_ delegate: UICalendarViewDelegate & UICalendarSelectionSingleDateDelegate) {
        calendarView.delegate = delegate
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: delegate)
        calendarView.selectionBehavior = dateSelection
    }
}
