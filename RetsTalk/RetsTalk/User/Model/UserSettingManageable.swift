//
//  UserSettingManageable.swift
//  RetsTalk
//
//  Created by HanSeung on 11/25/24.
//

import Combine
import Foundation

protocol UserSettingManageable: Sendable, ObservableObject {
    var userData: UserData { get set }
    /// 사용자 정보를 초기화하거나 가져오는 함수입니다.
    ///
    /// 비동기적으로 저장된 사용자 정보를 가져오고 아이디를 반환합니다.
    /// 만약 정보가 없으면, 새로운 사용자 정보를 저장하고 반환합니다.
    /// - Returns: 사용자 아이디
    func initialize() async -> UUID?
    /// 로컬 저장소의 사용자 데이터를 가져옵니다.
    func fetch()
    /// 로컬 저장소의 사용자 정보를 업데이트합니다.
    /// - Parameter userData: 새로 업데이트하는 사용자 정보
    func updateNickname(_ nickname: String)
    func updateCloudSyncState(state isOn: Bool)
    func updateNotificationStatus(_ isOn: Bool, at date: Date)
}
