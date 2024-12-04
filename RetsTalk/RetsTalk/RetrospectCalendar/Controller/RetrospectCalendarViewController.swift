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
    private var retrospectsCache: [DateComponents: [Retrospect]]
    
    private var loadedMonths: [(Int, Int)]
    
    private var retrospectTableViewController: RetrospectCalendarTableViewController?
    
    // MARK: View
    
    private let retrospectCalendarView = RetrospectCalendarView()
    
    // MARK: Initalization
    
    init(retrospectManager: RetrospectManageable) {
        self.retrospectManager = retrospectManager
        
        retrospectsSubject = CurrentValueSubject([])
        errorSubject = CurrentValueSubject(nil)
        retrospectsCache = [:]
        loadedMonths = []
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ViewController lifecycle
    
    override func loadView() {
        view = retrospectCalendarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        retrospectsCache = [:]
        loadedMonths = []
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
    
    override func setupSubscription() {
        super.setupSubscription()
        
        retrospectsSubject
            .sink { [weak self] retrospects in
                self?.retrospectsUpdateData(retrospects)
            }
            .store(in: &subscriptionSet)
    }
    
    // MARK: Retrospect manager action
    
    private func loadRetrospects(year: Int, month: Int) {
        guard !loadedMonths.contains(where: { $0 == (year, month) }),
              let currentMonth = Date.startOfMonth(year: year, month: month),
              let nextMonth = Date.startOfMonth(year: year, month: month + 1) else { return }
        
        Task { [weak self] in
            await self?.retrospectManager.fetchRetrospects(of: [.monthly(from: currentMonth, to: nextMonth)])
            if let fetchRetrospects = await self?.retrospectManager.retrospects {
                let newRetrospects = self?.filterNewRetrospects(fetchRetrospects) ?? []
                self?.retrospectsSubject.send(newRetrospects)
                self?.loadedMonths.append((year, month))
            }
        }
    }
    
    private func filterNewRetrospects(_ fetchedRetrospects: [Retrospect]) -> [Retrospect] {
        fetchedRetrospects.filter { fetchedretrospects in
            let dateComponents = fetchedretrospects.createdAt.toDateComponents
            guard let cachedRetrospects = retrospectsCache[dateComponents] else { return true }
            
            return !cachedRetrospects.contains(where: { $0.id == fetchedretrospects.id })
        }
    }
    
    // MARK: Retrospect data changed action
    
    private func retrospectsUpdateData(_ retrospects: [Retrospect]) {
        var dateComponents: Set<DateComponents> = []
        retrospects.forEach { retrospect in
            addRetrospectToCache(retrospect)
            let components = retrospect.createdAt.toDateComponents
            dateComponents.insert(components)
        }
        
        retrospectCalendarView.reloadDecorations(forDateComponents: Array(dateComponents))
    }
    
    private func addRetrospectToCache(_ retrospect: Retrospect) {
        let dateComponents = retrospect.createdAt.toDateComponents
        retrospectsCache[dateComponents, default: []].append(retrospect)
    }
    
    private func setupInitialData() {
        let currentDataComponents = retrospectCalendarView.currentDataComponents()
        guard let year = currentDataComponents.year,
              let month = currentDataComponents.month else { return }
        
        loadRetrospects(year: year, month: month)
    }
}

// MARK: - CalendarViewDelegate conformance

extension RetrospectCalendarViewController: @preconcurrency UICalendarViewDelegate {
    func calendarView(
        _ calendarView: UICalendarView,
        decorationFor dateComponents: DateComponents
    ) -> UICalendarView.Decoration? {
        guard let resultRetrospects = retrospectsCache[dateComponents.normalized],
              !resultRetrospects.isEmpty else { return nil }
        
        return .default(color: .blazingOrange)
    }
    
    func calendarView(
        _ calendarView: UICalendarView,
        didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents
    ) {
        let currentDateComponents = retrospectCalendarView.currentDataComponents()
        guard let currentYear = currentDateComponents.year,
              let currentMonth = currentDateComponents.month else { return }
        
        loadRetrospects(year: currentYear, month: currentMonth)
    }
}

// MARK: - CalendarSelectionSingleDateDelegate conformance

extension RetrospectCalendarViewController: @preconcurrency UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents?.normalized else { return }
        
        if let currentDateRetrospects = retrospectsCache[dateComponents.normalized] {
            presentRetrospectsList(retrospects: currentDateRetrospects)
        } else {
            retrospectTableViewController?.dismiss(animated: true) {
                self.retrospectTableViewController = nil
            }
        }
    }
    
    // MARK: Present retrospect TableView
    
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
        let controller = RetrospectCalendarTableViewController(
            retrospects: retrospects,
            retrospectManager: retrospectManager
        )
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        controller.presentationController?.delegate = self
        return controller
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate conformance

extension RetrospectCalendarViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if presentationController.presentedViewController === retrospectTableViewController {
            retrospectTableViewController = nil
        }
    }
}

// MARK: - Constants

private extension RetrospectCalendarViewController {
    enum Texts {
        static let CalendarViewTitle = "달력"
    }
}
