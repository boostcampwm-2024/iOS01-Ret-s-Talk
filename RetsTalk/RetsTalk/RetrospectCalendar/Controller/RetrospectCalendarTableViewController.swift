//
//  RetrospectCalendarTableViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 12/1/24.
//

import SwiftUI
import UIKit

final class RetrospectCalendarTableViewController: BaseViewController {
    private typealias DataSource = UITableViewDiffableDataSource<Section, Retrospect>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Retrospect>
    
    private var retrospectCalendarManager: RetrospectCalendarManageable
    
    private var dataSource: DataSource?
    private var snapshot: Snapshot?
    
    private var retrospects: [Retrospect]
    
    // MARK: View
    
    private let retrospectCalendarTableView = RetrospectCalendarTableView()
    
    // MARK: Initalization
    
    init(retrospects: [Retrospect], retrospectCalendarManager: RetrospectCalendarManageable) {
        self.retrospects = retrospects
        self.retrospectCalendarManager = retrospectCalendarManager
        
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
    
    // MARK: Update data
    
    private func updateTableView() {
        var snapshot = Snapshot()
        snapshot.appendSections([.retrospect])
        snapshot.appendItems(retrospects, toSection: .retrospect)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func updateRetrospect(with currentRetrospects: [Retrospect]) {
        retrospects = currentRetrospects
        updateTableView()
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
