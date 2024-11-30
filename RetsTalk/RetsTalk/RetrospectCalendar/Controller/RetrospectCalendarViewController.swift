//
//  RetrospectCalendarViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/30/24.
//

import Foundation

final class RetrospectCalendarViewController: BaseViewController {
    private let retrospectCalendarView: RetrospectCalendarView
    
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
    }
    
    override func loadView() {
        view = retrospectCalendarView
    }
}
