//
//  UITextField.swift
//  HJSwift
//
//  Created by PAN on 2017/10/13.
//  Copyright © 2017年 YR. All rights reserved.
//

import UIKit

private var kAssociationKeyMaxLength: Int = 0

extension UITextField {
    @IBInspectable open var placeHolderColor: UIColor? {
        set {
            setValue(newValue, forKeyPath: "placeholderLabel.textColor")
            setNeedsLayout()
        }
        get {
            return value(forKeyPath: "placeholderLabel.textColor") as? UIColor
        }
    }

    @IBInspectable open var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            removeTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }

    @objc private func checkMaxLength(textField: UITextField) {
        DispatchQueue._onMainThread {
            self.undoManager?.removeAllActions()

            guard let prospectiveText = self.text,
                  prospectiveText.count > self.maxLength,
                  self.maxLength > 0
            else {
                return
            }
            if let markedTextRange = self.markedTextRange {
                let pos = self.position(from: markedTextRange.start, offset: 0)
                if pos != nil {
                    return
                }
            }

            let selection = self.selectedTextRange
            let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: self.maxLength)
            let substring = prospectiveText[..<indexEndOfText]
            self.text = String(substring)
            self.selectedTextRange = selection
        }
    }
}
