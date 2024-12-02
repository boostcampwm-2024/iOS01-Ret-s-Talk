//
//  RetrospectCalendarViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/30/24.
//

import Combine
import UIKit

final class RetrospectCalendarViewController: BaseViewController {
    private let retrospectManager: RetrospectManageable
    
    private let retrospectsSubject: CurrentValueSubject<[Retrospect], Never>
    private let errorSubject: CurrentValueSubject<Error?, Never>
    private var retrospectsCache: [DateComponents: [Retrospect]] = [:]
    
    private var retrospectTableViewController: RetrospectCalendarTableViewController?
    
    // MARK: View
    
    private let retrospectCalendarView = RetrospectCalendarView()
    
    // MARK: Initalization
    
    init(retrospectManager: RetrospectManageable) {
        self.retrospectManager = retrospectManager
        
        retrospectsSubject = CurrentValueSubject([])
        errorSubject = CurrentValueSubject(nil)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = retrospectCalendarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRetrospects()
    }
    
    // MARK: RetsTalk lifecycle
    
    override func setupDelegation() {
        super.setupDelegation()
        
        retrospectCalendarView.setCalendarViewDelegate(self)
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        title = Texts.CalendarViewTitle
    }
    
    override func setupSubscription(on subscriptionSet: inout Set<AnyCancellable>) {
        super.setupSubscription(on: &subscriptionSet)
        
        retrospectsSubject
            .sink { [weak self] retrospects in
                self?.retrospectsUpdateData(retrospects)
            }
            .store(in: &subscriptionSet)
    }
    
    // MARK: Retrospect Manager Action
    
    private func loadRetrospects() {
        Task { [weak self] in
            await self?.retrospectManager.fetchRetrospects(of: [.finished])
            if let fetchRetrospects = await self?.retrospectManager.retrospects {
                self?.retrospectsSubject.send(fetchRetrospects)
            }
        }
    }
    
    // MARK: Retrospect Data Changed Action
    
    private func retrospectsUpdateData(_ retrospects: [Retrospect]) {
        var dateComponents: Set<DateComponents> = []
        
        retrospects.forEach {
            addRetrospectToCache($0)
            let components = normalizedDateComponents(from: $0.createdAt)
            dateComponents.insert(components)
        }
        
        retrospectCalendarView.reloadDecorations(forDateComponents: Array(dateComponents))
    }
    
    private func addRetrospectToCache(_ retrospect: Retrospect) {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: retrospect.createdAt)
        retrospectsCache[dateComponents, default: []].append(retrospect)
    }
}

// MARK: - CalendarViewDelegate

extension RetrospectCalendarViewController: @preconcurrency UICalendarViewDelegate {
    func calendarView(
        _ calendarView: UICalendarView,
        decorationFor dateComponents: DateComponents
    ) -> UICalendarView.Decoration? {
        let normalizedDate = normalizedDateComponents(from: dateComponents)
        guard let resultRetrospects = retrospectsCache[normalizedDate], !resultRetrospects.isEmpty else { return nil }
        
        return .default(color: .blazingOrange)
    }
}

// MARK: - CalendarSelectionSingleDateDelegate

extension RetrospectCalendarViewController: @preconcurrency UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents else { return }
        
        let selectedDate = normalizedDateComponents(from: dateComponents)
        if let currentDateRetrospects = retrospectsCache[selectedDate] {
            presentRetrospectsList(retrospects: currentDateRetrospects)
        } else {
            retrospectTableViewController?.dismiss(animated: true) {
                self.retrospectTableViewController = nil
            }
        }
    }
    
    // MARK: Present Retrospect TableView 
    
    private func presentRetrospectsList(retrospects: [Retrospect]) {
        let controller = retrospectTableViewController ?? createRetrospectTableViewController(retrospects: retrospects)
        controller.updateRetrospect(with: retrospects)
        
        if retrospectTableViewController == nil {
            retrospectTableViewController = controller
            present(controller, animated: true)
        }
    }
    
    private func createRetrospectTableViewController(retrospects: [Retrospect])
    -> RetrospectCalendarTableViewController {
        let controller = RetrospectCalendarTableViewController(retrospects: retrospects)
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        controller.presentationController?.delegate = self
        return controller
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension RetrospectCalendarViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // 모달이 닫히면 retrospectTableViewController를 nil로 설정
        if presentationController.presentedViewController === retrospectTableViewController {
            retrospectTableViewController = nil
        }
    }
}

// MARK: - DateComponents Helper

extension RetrospectCalendarViewController {
    private func normalizedDateComponents(from dateComponents: DateComponents) -> DateComponents {
        guard let date = Calendar.current.date(from: dateComponents) else { return DateComponents() }
        
        return normalizedDateComponents(from: date)
    }
    
    private func normalizedDateComponents(from date: Date) -> DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: date)
    }
}

// MARK: - Constants

private extension RetrospectCalendarViewController {
    enum Texts {
        static let CalendarViewTitle = "달력"
    }
}
