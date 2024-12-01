//
//  RetrospectListViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import Combine
import SwiftUI
import UIKit

final class RetrospectListViewController: BaseViewController {
    private let retrospectManager: RetrospectManageable
    private let userDefaultsManager: UserDefaultsManager
    private let userSettingManager: UserSettingManager

    private var subscriptionSet: Set<AnyCancellable>
    private var retrospectsSubject: CurrentValueSubject<[[Retrospect]], Never>
    private let errorSubject: CurrentValueSubject<Error?, Never>
    
    private let retrospectListView: RetrospectListView
    
    init(
        retrospectManager: RetrospectManageable,
        userDefaultsManager: UserDefaultsManager
    ) {
        self.retrospectManager = retrospectManager
        self.userDefaultsManager = userDefaultsManager
        userSettingManager = UserSettingManager(userDataStorage: userDefaultsManager)

        retrospectListView = RetrospectListView()
        retrospectsSubject = CurrentValueSubject([])
        errorSubject = CurrentValueSubject(nil)
        subscriptionSet = []
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        let coreDataManager = CoreDataManager(name: Constants.CoreDataContainerName, completion: { _ in })
        let clovaStudioManager = CLOVAStudioManager(urlSession: .shared)
        retrospectManager = RetrospectManager(
            userID: UUID(),
            retrospectStorage: coreDataManager,
            retrospectAssistantProvider: clovaStudioManager
        )
        userDefaultsManager = UserDefaultsManager()
        userSettingManager = UserSettingManager(userDataStorage: userDefaultsManager)

        retrospectListView = RetrospectListView()
        retrospectsSubject = CurrentValueSubject([])
        errorSubject = CurrentValueSubject(nil)
        subscriptionSet = []

        super.init(coder: coder)
    }
    
    // MARK: ViewController lifecycle method
    
    override func loadView() {
        view = retrospectListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addObserver()
        retrospectListView.setTableViewDelegate(self)
        subscribeRetrospects()
        addCreateButtondidTapAction()
        
        fetchInitialRetrospect()
    }
    
    // MARK: RetsTalk lifecycle method
    
    override func setupNavigationBar() {
        title = Texts.navigationTitle
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

    // MARK: Regarding iCloud

    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refetchRetrospects),
            name: .coreDataImportedNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(regenerateAndReplaceCoreDataManager),
            name: .iCloudSyncStateChangeNotification,
            object: nil
        )
    }

    @objc private func refetchRetrospects() {
        print("동기화 완료되어 패치 요청")
        fetchInitialRetrospect()
    }

    @objc private func regenerateAndReplaceCoreDataManager() {
        let userData = userSettingManager.userData
        let isCloudSyncOn = userData.isCloudSyncOn
        let newCoreDataManager = CoreDataManager(
            isiCloudSynced: isCloudSyncOn,
            name: Constants.CoreDataContainerName) { _ in }
        Task {
            await retrospectManager.replaceRetrospectStorage(newCoreDataManager)
        }
    }

    // MARK: Retrospect handling
    
    private func sortAndSendRetrospects() {
        Task {
            let sortedRetrospects = RetrospectSortingHelper.execute(await retrospectManager.retrospects)
            retrospectsSubject.send(sortedRetrospects)
        }
    }
    
    private func fetchInitialRetrospect() {
        Task {
            await retrospectManager.fetchRetrospects(of: [.pinned, .inProgress, .finished])
            sortAndSendRetrospects()
        }
    }
    
    private func deleteRetrospect(_ retrospect: Retrospect) {
        Task {
            await self.retrospectManager.deleteRetrospect(retrospect)
            self.sortAndSendRetrospects()
        }
    }
    
    private func togglepPinRetrospect(_ retrospect: Retrospect) {
        Task {
            await self.retrospectManager.togglePinRetrospect(retrospect)
            self.sortAndSendRetrospects()
        }
    }
    
    private func subscribeRetrospects() {
        retrospectsSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                retrospectListView.reloadData()
            }
            .store(in: &subscriptionSet)
    }
    
    // MARK: Action controls

    @objc private func didTapSettings() {
        let notificationManager = NotificationManager()
        let userSettingViewController = UserSettingViewController(
            userSettingManager: userSettingManager,
            notificationManager: notificationManager
        )
        navigationController?.pushViewController(userSettingViewController, animated: true)
    }
    
    private func addCreateButtondidTapAction() {
        retrospectListView.addCreateButtonAction(
            UIAction(
                handler: { [weak self] _ in
                    guard let self = self else { return }
                    
                    Task {
                        guard let retrospectChatManager = await retrospectManager.createRetrospect() else { return }
                        let chattingViewController = await RetrospectChatViewController(
                            retrospect: retrospectChatManager.retrospect,
                            retrospectChatManager: retrospectChatManager
                        )
                        navigationController?.pushViewController(chattingViewController, animated: true)
                    }
                })
        )
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
            return Texts.pinnedSectionTitle
        case 1:
            return Texts.inProgressSectionTitle
        case 2:
            return Texts.pastRetrospectSectionTitle
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
            let retrospect = retrospectsSubject.value[indexPath.section][indexPath.row]
            guard let retrospectChatManager = await retrospectManager.retrospectChatManager(of: retrospect)
            else { return }
            
            let chattingViewController = RetrospectChatViewController(
                retrospect: retrospect,
                retrospectChatManager: retrospectChatManager
            )
            navigationController?.pushViewController(chattingViewController, animated: true)
        }
    }
    
    // MARK: SwipeAction handling
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
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
                self?.deleteRetrospect(retrospect)
            },
            completionHandler: { _ in }
        )
        guard retrospect.status == .finished else { return [deleteAction] }
        
        let pinAction = pinAction(by: retrospect)
        return [deleteAction, pinAction]
    }
    
    private func pinAction(by retrospect: Retrospect) -> UIContextualAction {
        let pinToggleAction = { [weak self] in
            guard let self = self else { return }
            
            self.togglepPinRetrospect(retrospect)
        }
        
        let pinAction = UIContextualAction.actionWithSystemImage(
            named: Texts.pinIconImageName,
            tintColor: .blazingOrange,
            action: pinToggleAction,
            completionHandler: { _ in }
        )
        
        let unpinAction = UIContextualAction.actionWithSystemImage(
            named: Texts.unpinIconImageName,
            tintColor: .blazingOrange,
            action: pinToggleAction,
            completionHandler: { _ in }
        )
        
        return retrospect.isPinned ? unpinAction : pinAction
    }
}

// MARK: - Constants

private extension RetrospectListViewController {
    enum Metrics {
        static let cellVerticalMargin = 6.0
        static let tableViewHeaderHeight = 36.0
    }
    
    enum Texts {
        static let settingButtonImageName = "gearshape"
        static let deleteIconImageName = "trash.fill"
        static let pinIconImageName = "pin.fill"
        static let unpinIconImageName = "pin.slash.fill"
        
        static let navigationTitle = "회고"
        static let pinnedSectionTitle = "고정됨"
        static let inProgressSectionTitle = "진행 중인 회고"
        static let pastRetrospectSectionTitle = "지난 날의 회고"
        
        static let defaultSummaryText = "대화를 종료해 요약을 확인하세요"
    }
}
