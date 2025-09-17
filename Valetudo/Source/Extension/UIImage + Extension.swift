//
//  UIImage + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 07.06.25.
//
import UIKit

public extension UIImage {
    static func textImage(_ text: String, font: UIFont = .boldSystemFont(ofSize: 24), color: UIColor = .black) -> UIImage {
        .combine(op: text, opFont: font, opColor: color, spacing: 0)
    }
    
    static func combine(
        left lhs: UIImage? = nil,
        right rhs: UIImage? = nil,
        op: String = "➕",
        opFont: UIFont = .systemFont(ofSize: 12, weight: .regular),
        opColor: UIColor = .black,
        spacing: CGFloat = 0
    ) -> UIImage {
        // Attributes for plus string
        let attributes: [NSAttributedString.Key: Any] = [
            .font: opFont,
            .foregroundColor: opColor
        ]
        let lhsSize = lhs?.size ?? .zero
        let rhsSize = rhs?.size ?? .zero
        let opSize = (op as NSString).size(withAttributes: attributes)
        let totalWidth = lhsSize.width + spacing + opSize.width + spacing + rhsSize.width
        let maxHeight = max(lhsSize.height, opFont.lineHeight, rhsSize.height)
        let finalSize = CGSize(width: totalWidth, height: maxHeight)

        let renderer = UIGraphicsImageRenderer(size: finalSize, format: .default())
        return renderer.image { ctx in
            let lhsOrigin = CGPoint(x: 0, y: (maxHeight - lhsSize.height) / 2)
            lhs?.draw(in: CGRect(origin: lhsOrigin, size: lhsSize))

            let opX = lhsSize.width + spacing
            let opY = (maxHeight - opFont.lineHeight) / 2
            let opRect = CGRect(x: opX, y: opY, width: opSize.width, height: opFont.lineHeight)
            (op as NSString).draw(in: opRect, withAttributes: attributes)

            let rhsX = opX + opSize.width + spacing
            let rhsOrigin = CGPoint(x: rhsX, y: (maxHeight - rhsSize.height) / 2)
            rhs?.draw(in: CGRect(origin: rhsOrigin, size: rhsSize))
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
