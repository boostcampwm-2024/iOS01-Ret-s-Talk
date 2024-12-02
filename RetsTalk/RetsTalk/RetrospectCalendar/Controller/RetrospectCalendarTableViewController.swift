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
    
    
    private var retrospects: [Retrospect]
    
    private var dataSource: DataSource?
    private var snapshot: Snapshot?
    
    private let retrospectCalendarTableView = RetrospectCalendarTableView()
    
    init(retrospects: [Retrospect]) {
        self.retrospects = retrospects
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = retrospectCalendarTableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewDataSourceSetUp()
        updateTableView()
    }
    
    private func tableViewDataSourceSetUp() {
        dataSource = DataSource(
            tableView: retrospectCalendarTableView.retrospectListTableView
        ) { tableView, indexPath, retrospect in
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.retrospectCellIdentifier, for: indexPath)
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.contentConfiguration = UIHostingConfiguration {
                RetrospectCell(
                    summary: retrospect.summary ?? Texts.defaultSummaryText,
                    createdAt: retrospect.createdAt,
                    isPinned: retrospect.isPinned
                )
            }
            return cell
        }
    }
    
    private func updateTableView() {
        var snapshot = Snapshot()
        snapshot.appendSections([.retrospect])
        snapshot.appendItems(retrospects, toSection: .retrospect)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func dataSetUp(currentRetrospects: [Retrospect]) {
        retrospects = currentRetrospects
        updateTableView()
    }
}

// MARK: - Table Section

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
}
