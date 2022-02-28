//
//  IBButton.swift
//  HJSwift
//
//  Created by PAN on 2017/8/29.
//  Copyright © 2017年 YR. All rights reserved.
//

import UIKit

@IBDesignable
open class IBButton: UIButton {

    public static var layoutSubviewsInjection: ((IBButton) -> Void)?

    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var borderColor: UIColor? {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var gradient: Bool = false {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var gradientLeftColor: UIColor = IBDesignableKit.defaultGradientLeftColor {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var gradientRightColor: UIColor = IBDesignableKit.defaultGradientRightColor {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var gradientVertical: Bool = false {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var gradientLocation: CGFloat = 0.3 {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var gradientShadowColor: UIColor? {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var gradientShadowOffset: CGFloat = 5.0 {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var normalColor: UIColor? {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var selectedColor: UIColor? {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var highlightedColor: UIColor? {
        didSet {
            setNeesUpdate()
        }
    }

    @IBInspectable public var disabledColor: UIColor? {
        didSet {
            setNeesUpdate()
        }
    }

    @available(*, deprecated, message: "use pointAreaExpend")
    @IBInspectable public var enlarge: CGFloat = 0 {
        didSet {
            pointAreaExpend = CGSize(width: enlarge, height: enlarge)
        }
    }

    @IBInspectable public var pointAreaExpend: CGSize = .zero

    override public var isSelected: Bool {
        didSet {
            updateBackgroundLayerState()
        }
    }

    override public var isEnabled: Bool {
        didSet {
            updateBackgroundLayerState()
        }
    }

    override open var isHighlighted: Bool {
        didSet {
            updateBackgroundLayerState()
        }
    }

    private var updateToken: UUID?
    private let backgroundLayer = CALayer()
    private var backgroundLayerImages: [UIControl.State.RawValue: UIImage] = [:]

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let enlargeRect = bounds.insetBy(dx: -pointAreaExpend.width, dy: -pointAreaExpend.height)
        return enlargeRect.contains(point)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        IBButton.layoutSubviewsInjection?(self)

        if #available(iOS 15.0, *) {
            self.configuration = nil
        }
        if backgroundLayer.superlayer == nil {
            layer.insertSublayer(backgroundLayer, at: 0)
        }
        if backgroundLayer.frame.size != bounds.size {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            backgroundLayer.frame = bounds
            _updateBackgroundRadiusImage()
            CATransaction.commit()
        }
    }

    private func setNeesUpdate() {
        let token = UUID()
        updateToken = token
        OperationQueue.main.addOperation {
            if self.updateToken == token {
                self._updateBackgroundRadiusImage()
            }
        }
    }

    private func _updateBackgroundRadiusImage() {
        let size = backgroundLayer.frame.size
        guard size.height > 0, size.width > 0 else {
            return
        }
        func setRadiusBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
            var image = image
            if let img = image, cornerRadius > 0 {
                image = UIImage.maskImageWithRoundedRect(img,
                                                         cornerRadius: CGFloat.minimum(size.height / 2, cornerRadius),
                                                         borderWidth: borderWidth,
                                                         borderColor: borderColor != nil ? borderColor! : UIColor.white)
            }
            backgroundLayerImages[state.rawValue] = image
        }

        if gradient {
            let left = gradientLeftColor
            let right = gradientRightColor
            let location1 = (gradientLocation > 0 && gradientLocation < 1) ? gradientLocation : 0.5
            let image = UIImage.gradientImage(colors: [left, right], size: size, locations: [Float(location1), 1], mode: gradientVertical ? .vertical : .horizontal)
            setRadiusBackgroundImage(image, for: .normal)
        } else if let color = normalColor {
            let image = UIImage.image(withColor: color, size: size)
            setRadiusBackgroundImage(image, for: .normal)
        } else {
            let image = UIImage.image(withColor: .clear, size: size)
            setRadiusBackgroundImage(image, for: .normal)
        }

        if let color = selectedColor {
            let image = UIImage.image(withColor: color, size: size)
            setRadiusBackgroundImage(image, for: .selected)
            // 取消选中时的按钮背景色
            setRadiusBackgroundImage(image, for: [.highlighted, .selected])
        }
        if let color = highlightedColor {
            let image = UIImage.image(withColor: color, size: size)
            setRadiusBackgroundImage(image, for: .highlighted)
        }
        if let color = disabledColor {
            let image = UIImage.image(withColor: color, size: size)
            setRadiusBackgroundImage(image, for: .disabled)
        }
        updateBackgroundLayerState()
    }

    private func updateBackgroundLayerState() {
        // 模仿系统样式
        let normalImage = backgroundLayerImages[UIButton.State.normal.rawValue]
        let cornerRadius = CGFloat.minimum(backgroundLayer.frame.height / 2, cornerRadius)

        if let image = backgroundLayerImages[state.rawValue] {
            backgroundLayer.contents = image.cgImage
        } else if state.contains(.disabled) {
            if adjustsImageWhenDisabled {
                backgroundLayer.contents = normalImage?._alpha(0.5).cgImage
            } else {
                backgroundLayer.contents = normalImage?.cgImage
            }
        } else if state.contains(.highlighted) {
            if adjustsImageWhenHighlighted {
                if buttonType == .system {
                    backgroundLayer.contents = normalImage?._alpha(0.2)._tint(color: .black.withAlphaComponent(0.35)).cgImage
                } else {
                    backgroundLayer.contents = normalImage?._alpha(0.9)._tint(color: .black.withAlphaComponent(0.45)).cgImage
                }
            } else {
                backgroundLayer.contents = normalImage?.cgImage
            }
        } else if state.contains(.selected) {
            backgroundLayer.contents = normalImage?.cgImage
        } else {
            backgroundLayer.contents = nil
        }

        if let shadowColor = gradientShadowColor {
            layer.masksToBounds = false
            layer.cornerRadius = cornerRadius
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = CGSize(width: 0, height: gradientShadowOffset)
            layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), cornerRadius: cornerRadius).cgPath
            layer.shadowOpacity = !isSelected && isEnabled ? 1 : 0
        } else {
            layer.cornerRadius = 0
            layer.shadowColor = UIColor.clear.cgColor
            layer.shadowOffset = .zero
        }
    }
}

private extension UIImage {
    func _alpha(_ value: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func _tint(color: UIColor, blendMode: CGBlendMode = .sourceAtop) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        let rect = CGRect(origin: CGPoint.zero, size: size)
        color.setFill()
        draw(in: rect)
        context.setBlendMode(blendMode)
        context.fill(rect)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
}
