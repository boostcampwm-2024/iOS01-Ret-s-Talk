//
//  BaseViewController.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

import UIKit

class BaseViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: UIKit lifecycle method
    
    override func loadView() { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.delegate = self
        setupNavigationBar()
    }
    
    // MARK: RetsTalk lifecycle method
    
    func setupNavigationBar() { }
    
    // MARK: Navigation handling
    
    /// 현재 네비게이션 컨트롤러 상태에 따라 뷰 컨트롤러를 pop 또는 dismiss합니다.
    func didTapNavigationBackButton() {
        if let navigationController = self.navigationController,
           navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
        
    /// 네비게이션 스택 위치를 기준으로, 스와이프 제스처로 뒤로가기 동작을 설정합니다.
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        navigationController.interactivePopGestureRecognizer?.isEnabled = navigationController.viewControllers.count > 1
    }
}
