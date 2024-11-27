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
    
    /// 시스템 아이콘 이름으로 tintColor를 적용한 후 주어진 비율로 크기 조정합니다.
    static func systemImage(named name: String, tintColor: UIColor, scaleFactor: CGFloat) -> UIImage? {
        guard let originalImage = UIImage(systemName: name) else { return nil }
        
        let tintedImage = originalImage.withTintColor(tintColor, renderingMode: .alwaysOriginal)
        
        let originalSize = tintedImage.size
        let targetSize = CGSize(width: originalSize.width * scaleFactor, height: originalSize.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            tintedImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resizedImage
    }
}
