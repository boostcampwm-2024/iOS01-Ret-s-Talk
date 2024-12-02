//
//  RetrospectCalendarView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/30/24.
//

import UIKit

final class RetrospectCalendarView: UIView {
    private let retrospectCalendarView = UICalendarView()
    
    // MARK: Initalization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .backgroundMain
        retrospectCalendarViewSetUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View SetUp
    
    private func retrospectCalendarViewSetUp() {
        addSubview(retrospectCalendarView)
        
        retrospectCalendarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            retrospectCalendarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            retrospectCalendarView.leftAnchor.constraint(equalTo: leftAnchor, constant: Metrics.horizontalMargin),
            retrospectCalendarView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Metrics.horizontalMargin),
        ])
        
        retrospectCalendarView.wantsDateDecorations = true
        retrospectCalendarView.fontDesign = .rounded
        retrospectCalendarView.tintColor = .blazingOrange
    }
    
    func reloadDecorations(forDateComponents dateCompoenents: [DateComponents]) {
        retrospectCalendarView.reloadDecorations(forDateComponents: dateCompoenents, animated: true)
    }
    
    func setCalendarViewDelegate(_ delegate: UICalendarViewDelegate & UICalendarSelectionSingleDateDelegate) {
        retrospectCalendarView.delegate = delegate
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: delegate)
        retrospectCalendarView.selectionBehavior = dateSelection
    }
}

// MARK: - Constants

private extension RetrospectCalendarView {
    enum Metrics {
        static let horizontalMargin = 16.0
    }
}
