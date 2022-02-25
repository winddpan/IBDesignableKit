//
//  IBTextView.swift
//  HJSwift
//
//  Created by PAN on 2018/9/29.
//  Copyright © 2018年 YR. All rights reserved.
//

import UIKit

private var kAssociationKeyMaxLength: Int = 0

@IBDesignable
open class IBTextView: UITextView {
    private enum Constants {
        public static let defaultiOSPlaceholderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0980392, alpha: 0.22)
    }

    public let placeholderLabel = UILabel()

    private var placeholderLabelConstraints = [NSLayoutConstraint]()

    @IBInspectable open var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    @IBInspectable open var placeholderColor: UIColor = IBTextView.Constants.defaultiOSPlaceholderColor {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }

    @IBInspectable public var containerInset: CGFloat {
        set {
            textContainer.lineFragmentPadding = newValue
            textContainerInset = UIEdgeInsets(top: newValue, left: newValue, bottom: newValue, right: newValue)
        }
        get {
            return textContainerInset.left
        }
    }

    @IBInspectable public var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    override open var font: UIFont! {
        didSet {
            if placeholderFont == nil {
                placeholderLabel.font = font
            }
        }
    }

    open var placeholderFont: UIFont? {
        didSet {
            let font = (placeholderFont != nil) ? placeholderFont : self.font
            placeholderLabel.font = font
        }
    }

    override open var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }

    override open var text: String! {
        didSet {
            updateAfterTextChanged()
        }
    }

    override open var attributedText: NSAttributedString! {
        didSet {
            updateAfterTextChanged()
        }
    }

    override open var textContainerInset: UIEdgeInsets {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)

        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.text = placeholder
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        updateConstraintsForPlaceholderLabel()
    }

    private func updateConstraintsForPlaceholderLabel() {
        var newConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(textContainerInset.left + textContainer.lineFragmentPadding))-[placeholder]",
                                                            options: [],
                                                            metrics: nil,
                                                            views: ["placeholder": placeholderLabel])
        newConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(textContainerInset.top))-[placeholder]",
                                                         options: [],
                                                         metrics: nil,
                                                         views: ["placeholder": placeholderLabel])
        newConstraints.append(NSLayoutConstraint(item: placeholderLabel,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .width,
                                                 multiplier: 1.0,
                                                 constant: -(textContainerInset.left + textContainerInset.right + textContainer.lineFragmentPadding * 2.0)))
        removeConstraints(placeholderLabelConstraints)
        addConstraints(newConstraints)
        placeholderLabelConstraints = newConstraints
    }

    @objc private func textDidChange(_ notify: Notification) {
        guard notify.object as? Self === self else { return }
        updateAfterTextChanged()
    }

    private func updateAfterTextChanged() {
        DispatchQueue._onMainThread {
            self.placeholderLabel.isHidden = !self.text.isEmpty
            self.checkMaxLength()
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }

    private func checkMaxLength() {
        undoManager?.removeAllActions()

        guard let prospectiveText = text,
              prospectiveText.count > maxLength,
              self.maxLength > 0
        else {
            return
        }

        if let markedTextRange = markedTextRange {
            let pos = position(from: markedTextRange.start, offset: 0)
            if pos != nil {
                return
            }
        }
        let selection = selectedTextRange

        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        selectedTextRange = selection
    }
}
