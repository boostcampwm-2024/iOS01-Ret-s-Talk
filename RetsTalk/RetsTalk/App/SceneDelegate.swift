//
//  SceneDelegate.swift
//  RetsTalk
//
//  Created by HanSeung on 11/4/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var isFirstlLaunch: Bool = false

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let userDefaultsManager = UserDefaultsManager()
        let userSettingManager = UserSettingManager(userDataStorage: userDefaultsManager)
        
        let (userID, isFirstLaunch) = userSettingManager.initialize()
        let coreDataManager = CoreDataManager(
            inMemory: false,
            isiCloudSynced: userSettingManager.userData.isCloudSyncOn,
            name: Constants.Texts.coreDataContainerName
        ) { _ in }
        
        let retrospectAssistantProvider = CLOVAStudioManager(urlSession: .shared)
        
        let retrospectManager = RetrospectManager(
            userID: userID ?? Constants.defaultUUID,
            retrospectStorage: coreDataManager,
            retrospectAssistantProvider: retrospectAssistantProvider
        )
        
        let navigationController = BaseNavigationController(
            rootView: RetrospectListViewController(
                retrospectManager: retrospectManager,
                userDefaultsManager: userDefaultsManager,
                isFirstLaunch: isFirstLaunch
            )
        )
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
