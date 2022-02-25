//
//  IBLabel.swift
//  HJSwift
//
//  Created by PAN on 2017/10/13.
//  Copyright © 2017年 YR. All rights reserved.
//

import UIKit

@IBDesignable
open class IBLabel: UILabel {
    @IBInspectable
    open var leading: CGFloat = 0 {
        didSet {
            update()
        }
    }

    @IBInspectable
    open var IBShadowColor: UIColor? {
        didSet {
            layer.shadowColor = IBShadowColor?.cgColor
            layer.shadowOpacity = 1
            layer.masksToBounds = false
        }
    }

    @IBInspectable
    open var IBShadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = IBShadowRadius
            layer.masksToBounds = false
        }
    }

    @IBInspectable
    open var IBShadowOffset = CGSize.zero {
        didSet {
            layer.shadowOffset = IBShadowOffset
            layer.masksToBounds = false
        }
    }

    override open var text: String? {
        didSet {
            update()
        }
    }

    private func update() {
        let leading = CGFloat.maximum(self.leading, 0)
        if leading > 0 {
            numberOfLines = 0
        }

        if let text = text, !text.isEmpty {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = leading
            paragraph.lineBreakMode = lineBreakMode
            paragraph.alignment = textAlignment

            let attr = [NSAttributedString.Key.font: font!,
                        NSAttributedString.Key.foregroundColor: textColor!,
                        NSAttributedString.Key.paragraphStyle: paragraph] as [NSAttributedString.Key: Any]

            let str = NSMutableAttributedString(string: text, attributes: attr)
            super.attributedText = str
        } else {
            super.attributedText = nil
        }
    }
}
