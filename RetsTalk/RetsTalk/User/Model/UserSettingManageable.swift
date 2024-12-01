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

    func fetch()
    func update(to userData: UserData)
}
