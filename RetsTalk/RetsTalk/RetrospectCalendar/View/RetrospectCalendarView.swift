//
//  RetrospectCalendarView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/30/24.
//

import UIKit

final class RetrospectCalendarView: BaseView {
    private let retrospectCalendarView: UICalendarView = {
        let calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.wantsDateDecorations = true
        calendarView.fontDesign = .rounded
        calendarView.tintColor = .blazingOrange
        calendarView.locale = Locale(identifier: "ko_KR")
        return calendarView
    }()
    
    // MARK: RetsTalk lifecycle
    
    override func setupStyles() {
        super.setupStyles()
        
        backgroundColor = .backgroundMain
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(retrospectCalendarView)
    }
    
    override func setupSubviewLayouts() {
        super.setupSubviewLayouts()
        
        setupRetrospectCalendarViewLayouts()
    }
    
    // MARK: Delegation
    
    func setCalendarViewDelegate(_ delegate: UICalendarViewDelegate & UICalendarSelectionSingleDateDelegate) {
        retrospectCalendarView.delegate = delegate
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: delegate)
        retrospectCalendarView.selectionBehavior = dateSelection
    }
    
    // MARK: CalendarView action
    
    func reloadDecorations(forDateComponents dateCompoenents: [DateComponents]) {
        retrospectCalendarView.reloadDecorations(forDateComponents: dateCompoenents, animated: true)
    }
    
    func currentDataComponents() -> DateComponents {
        retrospectCalendarView.visibleDateComponents
    }
}

// MARK: - Subviews layouts

fileprivate extension RetrospectCalendarView {
    func setupRetrospectCalendarViewLayouts() {
        NSLayoutConstraint.activate([
            retrospectCalendarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            retrospectCalendarView.leftAnchor.constraint(equalTo: leftAnchor, constant: Metrics.horizontalMargin),
            retrospectCalendarView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Metrics.horizontalMargin),
        ])
    }
}

// MARK: - Constants

private extension RetrospectCalendarView {
    enum Metrics {
        static let horizontalMargin = 16.0
    }
}
