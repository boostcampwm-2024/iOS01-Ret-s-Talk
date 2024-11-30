//
//  RetrospectCalendarViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/30/24.
//

import Foundation
import UIKit

@MainActor
final class RetrospectCalendarViewController: BaseViewController {
    private let retrospectCalendarView: RetrospectCalendarView
    private var selectedDate: DateComponents?
    
    // MARK: Initalization
    
    init() {
        retrospectCalendarView = RetrospectCalendarView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrospectCalendarView.setCalendarViewDelegate(self)
    }
    
    override func loadView() {
        view = retrospectCalendarView
    }
}

// MARK: - CalendarViewDelegate

extension RetrospectCalendarViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, didSelect dateComponents: DateComponents) {
        selectedDate = dateComponents
        print("Selected date: \(dateComponents)")
    }
}

extension RetrospectCalendarViewController: @preconcurrency UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        
        selectedDate = dateComponents
        print("Selet\(selectedDate)")
    }
    
}
