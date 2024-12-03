//
//  BaseViewController.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

import Combine
import UIKit

class BaseViewController: UIViewController {
    var subscriptionSet: Set<AnyCancellable>
    
    // MARK: Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        subscriptionSet = []
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        subscriptionSet = []
        
        super.init(coder: coder)
    }
    
    // MARK: ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegation()
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
        setupSubscription()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        subscriptionSet.removeAll()
    }
    
    // MARK: RetsTalk lifecycle
    
    func setupDelegation() {}
    
    func setupDataSource() {}
    
    func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .blazingOrange
    }
    
    func setupSubscription() {}
}
