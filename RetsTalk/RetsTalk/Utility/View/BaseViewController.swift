//
//  BaseViewController.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

import UIKit

class BaseViewController: UIViewController, UINavigationControllerDelegate {
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }


    /// 현재 네비게이션 컨트롤러 상태에 따라 뷰 컨트롤러를 pop 또는 dismiss합니다.
    func didTapNavigationBackButton() {
        if let navigationController = self.navigationController,
           navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: UINavigationControllerDelegate conformance
    
    /// 네비게이션 스택 위치를 기준으로, 스와이프 제스처로 뒤로가기 동작을 설정합니다.
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        navigationController.interactivePopGestureRecognizer?.isEnabled = navigationController.viewControllers.count > 1
    }
}
