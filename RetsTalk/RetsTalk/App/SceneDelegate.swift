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
        
        let navigationController = UINavigationController(rootViewController: ChattingViewController())
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    // TODO: - 앱 백그라운드 종료 시 CoreData 저장 추가 예정
    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}
