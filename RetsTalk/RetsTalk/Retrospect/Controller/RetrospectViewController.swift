//
//  RetrospectViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import UIKit
import SwiftUI

final class RetrospectListViewController: UIViewController {
    let retrospectListView = RetrospectListView()
    
    private let dataSource = [
        ("해야할 일의 절반밖에 못했지만, 속도보다 방향이 더 중요하다는 걸 배운 날이었다.", Date()),
        ("회고의 중요성을 깨닫고, 혼자만이 아닌 함께 성장하기 위해 남은 시간 동안 성실히 임할 것을 다짐.", Date()),
        ("계획을 계속 수정했지만, 그 과정 속에서 나의 우선순위를 다시 생각해볼 수 있었다.", Date()),
        ("혼자서는 막막했던 문제도 함께 고민하니 쉽게 풀리며, 협업의 힘을 실감한 하루였다.", Date()),
        ("코드 리뷰를 통해 생각지도 못한 개선점을 알게 되었고, 내 자신을 돌아볼 수 있는 계기가 되었다.", Date()),
        ("해야할 일의 절반밖에 못했지만, 속도보다 방향이 더 중요하다는 걸 배운 날이었다.", Date()),
        ("회고의 중요성을 깨닫고, 혼자만이 아닌 함께 성장하기 위해 남은 시간 동안 성실히 임할 것을 다짐.", Date()),
        ("계획을 계속 수정했지만, 그 과정 속에서 나의 우선순위를 다시 생각해볼 수 있었다.", Date()),
        ("혼자서는 막막했던 문제도 함께 고민하니 쉽게 풀리며, 협업의 힘을 실감한 하루였다.", Date()),
        ("코드 리뷰를 통해 생각지도 못한 개선점을 알게 되었고, 내 자신을 돌아볼 수 있는 계기가 되었다.", Date()),
    ]
    
    // MARK: ViewController lifecycle method
    
    override func loadView() {
        view = retrospectListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundMain // 임시 배경색 설정
        setUpNavigationBar()
        retrospectListView.setTableViewDelegate(self)
    }
    
    // MARK: Custom method
    
    private func setUpNavigationBar() {
        title = Texts.titleLabelText
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource conformance

extension RetrospectListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.retrospectCellIdentifier, for: indexPath)
        
        cell.backgroundColor = .clear
        cell.contentConfiguration = UIHostingConfiguration {
            RetrospectCell(summary: data.0, createdAt: data.1)
        }
        .margins(.vertical, Metrics.cellVerticalMargin)
        
        return cell
    }
    
    // MARK: Section 임시 생성 코드
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "11월"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Metrics.tableViewHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont.appFont(.heavyTitle)
            header.textLabel?.textColor = UIColor.black
            header.contentView.backgroundColor = .clear
        }
    }
}

// MARK: - Constants

private extension RetrospectListViewController {
    enum Metrics {
        static let cellVerticalMargin = 4.0
        static let tableViewHeaderHeight = 36.0
    }
    
    enum Texts {
        static let titleLabelText = "회고"
    }
}
