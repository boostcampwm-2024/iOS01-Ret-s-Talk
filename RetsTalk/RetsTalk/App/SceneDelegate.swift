//
//  SceneDelegate.swift
//  RetsTalk
//
//  Created by HanSeung on 11/4/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let userDefaultsManager = UserDefaultsManager()
        let userSettingManager = UserSettingManager(userDataStorage: userDefaultsManager)
        let userData = userSettingManager.userData
        let userID = UUID(uuidString: userData.userID) ?? UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
        let isiCloudSynced = userData.isCloudSyncOn
        let coreDataManager = CoreDataManager(
            inMemory: false,
            isiCloudSynced: isiCloudSynced,
            name: Constants.Texts.coreDataContainerName
        ) { _ in }
        let retrospectAssistantProvider = CLOVAStudioManager(urlSession: .shared)
        let retrospectManager = RetrospectManager(
            userID: userID,
            retrospectStorage: coreDataManager,
            retrospectAssistantProvider: retrospectAssistantProvider
        )
        let navigationController = customedNavigationController(
            rootViewController: RetrospectListViewController(
                retrospectManager: retrospectManager,
                userDefaultsManager: userDefaultsManager
            )
        )
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

// MARK: - Custom method

extension SceneDelegate {
    private func customedNavigationController(rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.backgroundColor = .systemBackground
        return navigationController
    }
}
