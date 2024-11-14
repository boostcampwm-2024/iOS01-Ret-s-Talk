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
    
    private let messages: [Message] = [
        Message(role: .assistant, content: "오늘은 무엇을 하셨나요?", createdAt: Date()),
        Message(role: .user, content: "오늘은 채팅 Cell을 구성했어요", createdAt: Date()+1),
        Message(role: .assistant, content: "어떻게 구성하셨나요?", createdAt: Date()+2),
        Message(role: .user, content: "Cell은 SwiftUI로 TableView에서는 Hosting을 사용했어요", createdAt: Date()+3),
        Message(role: .assistant, content: "리뷰를 통해 수정하겠군요", createdAt: Date()+4),
        Message(role: .assistant, content: "리뷰를 통해 수정하겠군요", createdAt: Date()+4),
        Message(role: .assistant, content: "리뷰를 통해 수정하겠군요", createdAt: Date()+4),
        Message(role: .assistant, content: "리뷰를 통해 수정하겠군요", createdAt: Date()+4),
        Message(role: .assistant, content: "리뷰를 통해 수정하겠군요", createdAt: Date()+4),
        Message(role: .assistant, content: "리뷰를 통해 수정하겠군요", createdAt: Date()+4),
        Message(role: .assistant, content: "리뷰를 통해 수정하겠군요", createdAt: Date()+4),
        Message(role: .assistant, content: "리뷰를 통해 수정하겠군요", createdAt: Date()+4),
    ]
    
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
