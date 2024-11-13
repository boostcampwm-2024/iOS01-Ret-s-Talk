//
//  ChattingViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit
import SwiftUI

final class ChattingViewController: UIViewController {
    private let chatView = ChatView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatView.chattingTableView.delegate = self
        chatView.chattingTableView.dataSource = self
    }
    
    override func loadView() {
        self.view = chatView
    }
    
}
