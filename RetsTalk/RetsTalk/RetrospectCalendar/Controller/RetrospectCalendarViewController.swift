//
//  RetrospectCalendarViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/30/24.
//

import Combine
import Foundation
import UIKit
import SwiftUI

final class RetrospectCalendarViewController: BaseViewController {
    private let retrospectManager: RetrospectManageable
    
    private let retrospectsSubject: CurrentValueSubject<[Retrospect], Never>
    private let errorSubject: CurrentValueSubject<Error?, Never>
    private var subscriptionSet: Set<AnyCancellable>
    private var retrospectsCache: [DateComponents: [Retrospect]] = [:]
    private var currentDateRetrospects: [Retrospect] = []
    
    private var dataSource: UITableViewDiffableDataSource<Section, Retrospect>?
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Retrospect>?
    
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
    
    override func loadView() {
        view = retrospectCalendarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrospectCalendarView.setCalendarViewDelegate(self)
        
        setUpNavigationBar()
        setUpDataSource()
        
        subscribeRetrospects()
        loadRetrospects()
    }
    
    // MARK: Navigation bar
    
    private func setUpNavigationBar() {
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
    
    // MARK: TableView SetUp
    
    private func setUpDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Retrospect>(
            tableView: retrospectCalendarView.retrospectListTableView
        ) { tableView, indexPath, retrospect in
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.retrospectCellIdentifier, for: indexPath)
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.contentConfiguration = UIHostingConfiguration {
                RetrospectCell(
                    summary: retrospect.summary ?? "",
                    createdAt: retrospect.createdAt,
                    isPinned: retrospect.isPinned
                )
            }
            return cell
        }
    }
    
    func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Retrospect>()
        snapshot.appendSections([.retrospect])
        snapshot.appendItems(currentDateRetrospects, toSection: .retrospect)
        dataSource?.apply(snapshot, animatingDifferences: true)
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
        guard let dateComponents = dateComponents else {
            print("선택된 날짜가 없습니다.")
            return
        }
        
        let selectedDate = normalizedDateComponents(from: dateComponents)
        currentDateRetrospects = retrospectsCache[selectedDate] ?? []
        
        updateTableView()
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

extension RetrospectCalendarViewController {
    enum Section {
        case retrospect
    }
}

// MARK: - Constants

extension RetrospectCalendarViewController {
    enum Texts {
        static let CalendarViewTitle = "달력"
    }
}
