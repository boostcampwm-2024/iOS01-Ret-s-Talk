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
        
        let mockRetrospectManager = MockRetrospectManager()
        let coreDataManager = CoreDataManager(inMemory: true, name: "RetsTalk") { _ in }
        let navigationController = customedNavigationController(
            rootViewController: RetrospectListViewController(
                retrospectManager: mockRetrospectManager,
                persistentStorage: coreDataManager
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
