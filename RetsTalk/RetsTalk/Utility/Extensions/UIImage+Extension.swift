//
//  UIImage+Extension.swift
//  RetsTalk
//
//  Created by HanSeung on 11/19/24.
//

import UIKit

extension UIImage {
    enum SystemImage {
        case leftChevron
        
        var name: String {
            switch self {
            case .leftChevron:
                return "chevron.left"
            }
        }
    }

    convenience init?(systemImage: SystemImage) {
        switch systemImage {
        case .leftChevron:
            self.init(systemName: systemImage.name)
        }
    }
}
