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
    
    private let messages: [Message] = Array(
        repeating: Message(role: .user, content: "안녕하세요", createdAt: Date()),
        count: 3
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatView.chattingTableView.delegate = self
        chatView.chattingTableView.dataSource = self
    }
    
    override func loadView() {
        self.view = chatView
    }
}

extension ChattingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = UITableViewCell()
        cell.contentConfiguration = UIHostingConfiguration {
            MessageCell(message: message.content, isUser: message.role == .user)
        }

        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        return cell
    }
}
