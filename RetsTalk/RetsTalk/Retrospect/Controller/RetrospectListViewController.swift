//
//  RetrospectViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import Combine
import SwiftUI
import UIKit

final class RetrospectListViewController: BaseViewController {
    private let retrospectManager: RetrospectManageable
    private let persistentStorage: Persistable
    
    private var subscriptionSet: Set<AnyCancellable>
    private var retrospectsSubject: CurrentValueSubject<[[Retrospect]], Never>
    private let errorSubject: CurrentValueSubject<Error?, Never>
    
    // MARK: UI Components
    
    let retrospectListView = RetrospectListView()
    
    init(retrospectManager: RetrospectManageable, persistentStorage: Persistable) {
        self.retrospectManager = retrospectManager
        self.persistentStorage = persistentStorage
        
        subscriptionSet = []
        retrospectsSubject = CurrentValueSubject([])
        errorSubject = CurrentValueSubject(nil)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ViewController lifecycle method
    
    override func loadView() {
        view = retrospectListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundMain
        setUpNavigationBar()
        retrospectListView.setTableViewDelegate(self)
        observeRetrospects()
        addCreateButtonTapAction()
        
        Task {
            await retrospectManager.fetchRetrospects(of: [.pinned, .inProgress, .finished])
            sortAndSendRetrospects()
        }
    }
    
    // MARK: Custom method
    
    private func sortAndSendRetrospects() {
        Task {
            let sortedRetrospects = RetrospectSortingHelper.execute(await retrospectManager.retrospects)
            retrospectsSubject.send(sortedRetrospects)
        }
    }
    
    private func observeRetrospects() {
        retrospectsSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                retrospectListView.reloadData()
            }
            .store(in: &subscriptionSet)
    }
    
    private func setUpNavigationBar() {
        title = Texts.titleLabelText
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: Texts.settingButtonImageName),
            style: .plain,
            target: self,
            action: #selector(didTapSettings)
        )
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = settingsButton
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc func didTapSettings() {
        let userSettingViewController = UserSettingViewController(
            userSettingManager: UserSettingManager(userDataStorage: UserDefaultsManager())
        )
        navigationController?.pushViewController(userSettingViewController, animated: true)
    }
    
    private func addCreateButtonTapAction() {
        retrospectListView.addCreateButtonAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            
            Task {
                let assistantMessageProvider = CLOVAStudioManager(urlSession: .shared)
                let retrospectChatManager = await RetrospectChatManager(
                    retrospect: Retrospect(id: UUID(), userID: retrospectManager.sharedUserID),
                    messageStorage: persistentStorage,
                    assistantMessageProvider: assistantMessageProvider,
                    retrospectChatManagerListener: retrospectManager
                )
                let chattingViewController = ChattingViewController(messageManager: retrospectChatManager)
                navigationController?.pushViewController(chattingViewController, animated: true)
            }
        }))
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource conformance

extension RetrospectListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Datasource handling
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        retrospectsSubject.value[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = retrospectsSubject.value[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.retrospectCellIdentifier, for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentConfiguration = UIHostingConfiguration {
            RetrospectCell(summary: data.summary ?? Texts.defaultSummaryText,
                           createdAt: data.createdAt,
                           isPinned: data.isPinned
            )
        }
        .margins(.vertical, Metrics.cellVerticalMargin)
        
        return cell
    }
    
    // MARK: Section handling
    
    func numberOfSections(in tableView: UITableView) -> Int {
        retrospectsSubject.value.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard retrospectsSubject.value[section].isNotEmpty else {
            return nil
        }
        
        switch section {
        case 0:
            return Texts.firstSectionTitle
        case 1:
            return Texts.secondSectionTitle
        case 2:
            return Texts.thirdSectionTitle
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Metrics.tableViewHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont.appFont(.title)
            header.textLabel?.textColor = .black
            header.contentView.backgroundColor = .clear
        }
    }
    
    // MARK: SelectRow handling
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Task {
            let assistantMessageProvider = CLOVAStudioManager(urlSession: URLSession.shared)
            let retrospectChatManager = await RetrospectChatManager(
                retrospect: retrospectsSubject.value[indexPath.section][indexPath.row],
                messageStorage: persistentStorage,
                assistantMessageProvider: assistantMessageProvider,
                retrospectChatManagerListener: retrospectManager
            )
            
            let chattingViewController = ChattingViewController(messageManager: retrospectChatManager)
            navigationController?.pushViewController(chattingViewController, animated: true)
        }
    }
    
    // MARK: SwipeAction handling
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration?
    {
        let selectedRetrospect = retrospectsSubject.value[indexPath.section][indexPath.row]
        
        let configuration = UISwipeActionsConfiguration(actions: retrospectSwipeAction(selectedRetrospect))
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    private func retrospectSwipeAction(_ retrospect: Retrospect) -> [UIContextualAction] {
        let deleteAction = UIContextualAction.actionWithSystemImage(
            named: Texts.deleteIconImageName,
            tintColor: .red,
            action: { [weak self] in
                guard let self = self else { return }
                Task {
                    await self.retrospectManager.deleteRetrospect(retrospect)
                    sortAndSendRetrospects()
                }
            },
            completionHandler: {_ in}
        )
        
        let pinAction = UIContextualAction.actionWithSystemImage(
            named: Texts.pinIconImageName,
            tintColor: .blazingOrange,
            action: { [weak self] in
                guard let self = self else { return }
                Task {
                    await self.retrospectManager.togglePinRetrospect(retrospect)
                    sortAndSendRetrospects()
                }
            },
            completionHandler: {_ in}
        )
        
        let unpinAction = UIContextualAction.actionWithSystemImage(
            named: Texts.unpinIconImageName,
            tintColor: .blazingOrange,
            action: { [weak self] in
                guard let self = self else { return }
                Task {
                    await self.retrospectManager.togglePinRetrospect(retrospect)
                    sortAndSendRetrospects()
                }
            },
            completionHandler: {_ in}
        )
        
        return retrospect.isPinned ? [deleteAction, unpinAction] : [deleteAction, pinAction]
    }
}

// MARK: - Constants

private extension RetrospectListViewController {
    enum Metrics {
        static let cellVerticalMargin = 6.0
        static let tableViewHeaderHeight = 36.0
    }
    
    enum Texts {
        static let titleLabelText = "회고"
        
        static let settingButtonImageName = "gearshape"
        static let deleteIconImageName = "trash.fill"
        static let pinIconImageName = "pin.fill"
        static let unpinIconImageName = "pin.slash.fill"
        
        
        
        static let firstSectionTitle = "고정됨"
        static let secondSectionTitle = "진행 중인 회고"
        static let thirdSectionTitle = "지난 날의 회고"
        
        static let defaultSummaryText = "대화를 종료해 요약을 확인하세요"
    }
}
