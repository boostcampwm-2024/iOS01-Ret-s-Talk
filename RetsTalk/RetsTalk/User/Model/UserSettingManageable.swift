//
//  UserSettingManageable.swift
//  RetsTalk
//
//  Created by HanSeung on 11/25/24.
//

import Foundation
import Combine

protocol UserSettingManageable: Sendable {
    var userDataSubject: CurrentValueSubject<UserData, Never> { get }

    func fetch() async throws
    func update(to: UserData) async throws
}
