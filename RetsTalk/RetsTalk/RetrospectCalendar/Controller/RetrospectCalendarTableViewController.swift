//
//  RetrospectCalendarTableViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 12/1/24.
//

@preconcurrency import Combine
import SwiftUI
import UIKit

final class RetrospectCalendarTableViewController: BaseViewController {
    private typealias DataSource = UITableViewDiffableDataSource<Section, Retrospect>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Retrospect>
    
    private var retrospectCalendarManager: RetrospectCalendarManageable
    
    private var dataSource: DataSource?
    private var snapshot: Snapshot?
    
    private var retrospectsSubject: CurrentValueSubject<[Retrospect], Never>
    private let errorSubject: PassthroughSubject<Error, Never>
    private var currentDateComponents: DateComponents 
    
    // MARK: View
    
    private let retrospectCalendarTableView = RetrospectCalendarTableView()
    
    // MARK: Initalization
    
    init(
        retrospectCalendarManager: RetrospectCalendarManageable,
        currentDateComponents: DateComponents
    ) {
        self.retrospectCalendarManager = retrospectCalendarManager
        
        retrospectsSubject = CurrentValueSubject([])
        errorSubject = PassthroughSubject()
        self.currentDateComponents = currentDateComponents
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: RetsTalk lifecycle
    
    override func loadView() {
        view = retrospectCalendarTableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        updateTableView()
    }
    
    override func setupDelegation() {
        super.setupDelegation()
        
        retrospectCalendarTableView.setupRetrospectListTableViewDelegate(self)
    }
    
    override func setupDataSource() {
        super.setupDataSource()
        
        setupDiffableDataSource()
    }
    
    override func setupSubscription() {
        super.setupSubscription()
        
        subscribeToRetrospectsPublisher()
        subscribeToRetrospects()
        subscribeToErrorPublisher()
        subscribeToError()
    }
    
    private func configureCell(cell: UITableViewCell, retrospect: Retrospect) {
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentConfiguration = UIHostingConfiguration {
            RetrospectCell(
                summary: retrospect.summary ?? Texts.defaultSummaryText,
                createdAt: retrospect.createdAt,
                isPinned: retrospect.isPinned
            )
        }
        .margins(.vertical, Metrics.cellVerticalPadding)
    }
    
    // MARK: Subscription method
    
    private func subscribeToRetrospectsPublisher() {
        Task {
            await retrospectCalendarManager.retrospectsPublisher
                .receive(on: RunLoop.main)
                .subscribe(retrospectsSubject)
                .store(in: &subscriptionSet)
        }
    }
    
    func retrospects(for dateComponents: DateComponents) -> [Retrospect] {
        return retrospectsSubject.value.filter {
            $0.createdAt.toDateComponents == dateComponents
        }
    }
    
    private func subscribeToRetrospects() {
        retrospectsSubject
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.updateTableView()
            }
            .store(in: &subscriptionSet)
    }
    
    private func subscribeToErrorPublisher() {
        Task {
            await retrospectCalendarManager.errorPublisher
                .receive(on: RunLoop.main)
                .subscribe(errorSubject)
                .store(in: &subscriptionSet)
        }
    }
    
    private func subscribeToError() {
        errorSubject
            .sink { _ in
                
            }
            .store(in: &subscriptionSet)
    }
    
    // MARK: Update data
    
    func updateRetrospect(currentDateComponents: DateComponents) {
        self.currentDateComponents = currentDateComponents
        updateTableView()
    }
}

private extension RetrospectCalendarTableViewController {
    func setupDiffableDataSource() {
        dataSource = DataSource(
            tableView: retrospectCalendarTableView.retrospectListTableView
        ) { tableView, indexPath, retrospect in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.Texts.retrospectCellIdentifier,
                for: indexPath
            )
            self.configureCell(cell: cell, retrospect: retrospect)
            return cell
        }
    }
    
    private func updateTableView() {
        var snapshot = Snapshot()
        snapshot.appendSections([.retrospect])
        let retrospectData = retrospectsSubject.value.filter { $0.createdAt.toDateComponents == self.currentDateComponents }
        snapshot.appendItems(retrospectData, toSection: .retrospect)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UITableViewDelegate conformance

extension RetrospectCalendarTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let retrospect = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        Task {
            guard let retrospectChatManager = await retrospectCalendarManager.retrospectChatManager(of: retrospect)
            else { return }
            
            let chattingViewController = RetrospectChatViewController(
                retrospect: retrospect,
                retrospectChatManager: retrospectChatManager
            )
            let navigationController = UINavigationController(rootViewController: chattingViewController)
            present(navigationController, animated: true)
        }
    }
}

// MARK: - Table section

private extension RetrospectCalendarTableViewController {
    enum Section {
        case retrospect
    }
}

// MARK: - Constants

private extension RetrospectCalendarTableViewController {
    enum Texts {
        static let defaultSummaryText = "대화를 종료해 요약을 확인하세요"
    }
    
    enum Metrics {
        static let cellVerticalPadding = 8.0
    }
}
