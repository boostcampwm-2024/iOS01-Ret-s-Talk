//
//  RetrospectCalendarViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/30/24.
//

import Combine
import Foundation
import UIKit

@MainActor
final class RetrospectCalendarViewController: BaseViewController {
    private let retrospectManager: RetrospectManageable
    
    private var retrospectsSubject: CurrentValueSubject<[Retrospect], Never>
    private let errorSubject: CurrentValueSubject<Error?, Never>
    private var subscriptionSet: Set<AnyCancellable>
    private var selectedDate: DateComponents?
    private var retrospectsCache: [DateComponents: [Retrospect]] = [:]
    
    private let retrospectCalendarView: RetrospectCalendarView

    // MARK: Initalization
    
    init(retrospectManager: RetrospectManageable) {
        self.retrospectManager = retrospectManager
        retrospectCalendarView = RetrospectCalendarView()
        
        retrospectsSubject = CurrentValueSubject([])
        errorSubject = CurrentValueSubject(nil)
        subscriptionSet = []
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrospectCalendarView.setCalendarViewDelegate(self)
        
        subscribeRetrospects()
        loadRetrospects()
    }
    
    override func loadView() {
        view = retrospectCalendarView
    }
    
    // MARK: Subscription
    
    private func subscribeRetrospects() {
        retrospectsSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] retrospects in
                guard let self = self else { return }
                
                var dateComponents: [DateComponents] = []
                retrospects.forEach {
                    self.addRetrospectToCache($0)
                    let components = self.normalizedDateComponents(from: $0.createdAt)
                    dateComponents.append(components)
                }
                self.retrospectCalendarView.reloadDecorations(forDateComponents: dateComponents)
            }
            .store(in: &subscriptionSet)
    }
    
    // MARK: RetrospectManager Action
    
    private func loadRetrospects() {
        Task { [weak self] in
            await self?.retrospectManager.fetchRetrospects(of: [.all])
            if let fetchRetrospects = await self?.retrospectManager.retrospects {
                self?.retrospectsSubject.send(fetchRetrospects)
            }
        }
    }
    
    private func addRetrospectToCache(_ retrospect: Retrospect) {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: retrospect.createdAt)
        retrospectsCache[dateComponents, default: []].append(retrospect)
    }
}

// MARK: - CalendarViewDelegate

extension RetrospectCalendarViewController: @preconcurrency UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, didSelect dateComponents: DateComponents) {
        selectedDate = dateComponents
        print("Selected date: \(dateComponents)")
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let day = dateComponents.day else {
            return nil
        }

        return day.isMultiple(of: 2) ? nil : .default(color: .blazingOrange)
    }
}

// MARK: - CalendarSelectionSingleDateDelegate

extension RetrospectCalendarViewController: @preconcurrency UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        print("선택된 날자: \(String(describing: dateComponents))")
    }
}

// MARK: - DateComponents Helper

    private func normalizedDateComponents(from dateComponents: DateComponents) -> DateComponents {
        guard let date = Calendar.current.date(from: dateComponents) else {
            return DateComponents()
        }
        
        return normalizedDateComponents(from: date)
    }
    
    private func normalizedDateComponents(from date: Date) -> DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: date)
    }
}
