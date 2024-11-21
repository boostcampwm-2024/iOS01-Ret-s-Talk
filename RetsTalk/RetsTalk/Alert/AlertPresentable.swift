//
//  AlertPresentable.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/21/24.
//

import UIKit

protocol AlertPresentable where Self: UIViewController {
    associatedtype Situation

    func presentAlert(for situation: Situation, actions: [UIAlertAction])
}
