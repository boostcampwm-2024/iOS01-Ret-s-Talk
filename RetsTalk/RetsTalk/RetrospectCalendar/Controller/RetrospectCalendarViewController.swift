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
    private var subscriptionSet: Set<AnyCancellable>
    private var retrospectsCache: [DateComponents: [Retrospect]] = [:]
    
    private let retrospectCalendarView = RetrospectCalendarView()
    
    private var retrospectTableViewController: RetrospectCalendarTableViewController?
    
    // MARK: Initalization
    
    init(retrospectManager: RetrospectManageable) {
        self.retrospectManager = retrospectManager
        
        retrospectsSubject = CurrentValueSubject([])
        errorSubject = CurrentValueSubject(nil)
        subscriptionSet = []
        
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
        
        retrospectCalendarView.setCalendarViewDelegate(self)
        
        subscribeRetrospects()
        loadRetrospects()
    }
    
    // MARK: Navigation bar
    
    override func setupNavigationBar() {
        title = Texts.CalendarViewTitle
    }
    
    // MARK: Subscription
    
    private func subscribeRetrospects() {
        retrospectsSubject
            .sink { [weak self] retrospects in
                self?.retrospectsUpdateData(retrospects)
            }
            .store(in: &subscriptionSet)
    }
    
    // MARK: RetrospectManager Action
    
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
        guard let currentDateRetrospects = retrospectsCache[selectedDate] else {
            retrospectTableViewController?.dismiss(animated: true) {
                self.retrospectTableViewController = nil
            }
            return
        }
        
        presentRetrospectsList(retrospects: currentDateRetrospects)
    }
    
    // MARK: Present Retrospect TableView 
    
    private func presentRetrospectsList(retrospects: [Retrospect]) {
        if let retrospectTableViewController = retrospectTableViewController {
            retrospectTableViewController.dataSetUp(currentRetrospects: retrospects)
            return
        }
        
        let newController = createRetrospectTableViewController(retrospects: retrospects)
        retrospectTableViewController = newController
        guard let retrospectTableViewController = retrospectTableViewController else { return }
        
        present(retrospectTableViewController, animated: true)
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
