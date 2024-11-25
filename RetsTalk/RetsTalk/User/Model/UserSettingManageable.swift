//
//  UserSettingManageable.swift
//  RetsTalk
//
//  Created by HanSeung on 11/25/24.
//

import Combine
import Foundation

protocol UserSettingManageable: Sendable {
    var userDataSubject: CurrentValueSubject<UserData, Never> { get }

    func fetch()
    func update(to userData: UserData)
}
