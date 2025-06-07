//
//  UIImage + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 07.06.25.
//
import UIKit

public extension UIImage {
    static func combine(
        left lhs: UIImage,
        right rhs: UIImage,
        text: String = "➕",
        textFont: UIFont = .systemFont(ofSize: 12, weight: .regular),
        textColor: UIColor = .black,
        spacing: CGFloat = 0
    ) -> UIImage {
        // Attributes for plus string
        let attributes: [NSAttributedString.Key: Any] = [
            .font: textFont,
            .foregroundColor: textColor
        ]
        let plusSize = (text as NSString).size(withAttributes: attributes)
        let totalWidth = lhs.size.width + spacing + plusSize.width + spacing + rhs.size.width
        let maxHeight = max(lhs.size.height, textFont.lineHeight, rhs.size.height)
        let finalSize = CGSize(width: totalWidth, height: maxHeight)

        let renderer = UIGraphicsImageRenderer(size: finalSize, format: .default())
        return renderer.image { ctx in
            let lhsOrigin = CGPoint(x: 0, y: (maxHeight - lhs.size.height) / 2)
            lhs.draw(in: CGRect(origin: lhsOrigin, size: lhs.size))

            let plusX = lhs.size.width + spacing
            let plusY = (maxHeight - textFont.lineHeight) / 2
            let plusRect = CGRect(x: plusX, y: plusY, width: plusSize.width, height: textFont.lineHeight)
            (text as NSString).draw(in: plusRect, withAttributes: attributes)

            let rhsX = plusX + plusSize.width + spacing
            let rhsOrigin = CGPoint(x: rhsX, y: (maxHeight - rhs.size.height) / 2)
            rhs.draw(in: CGRect(origin: rhsOrigin, size: rhs.size))
        }
    }

    convenience init?(color: UIColor) {
        let rect = CGRect(origin: .zero, size: .one)
        UIGraphicsBeginImageContextWithOptions(.one, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
