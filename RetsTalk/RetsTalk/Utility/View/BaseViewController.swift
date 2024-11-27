//
//  BaseViewController.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

import UIKit

class BaseViewController: UIViewController, UINavigationControllerDelegate {
    /// 현재 네비게이션 컨트롤러 상태에 따라 뷰 컨트롤러를 pop 또는 dismiss합니다.
    func onClickBack() {
            if let navigationController = self.navigationController,
                navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    
    // MARK:  UINavigationControllerDelegate conformance
    
    /// 네비게이션 스택 위치를 기준으로, 스와이프 제스처로 뒤로가기 동작을 설정합니다.
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController, animated: Bool
    ) {
        navigationController.interactivePopGestureRecognizer?.isEnabled = navigationController.viewControllers.count > 1
    }
}
