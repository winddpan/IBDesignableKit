//
//  IBGradientView.swift
//  HJSwift
//
//  Created by PAN on 2018/3/22.
//  Copyright © 2018年 YR. All rights reserved.
//

import UIKit

@IBDesignable open class IBGradientView: UIView {
    @IBInspectable open var startColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var endColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var borderColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var borderWidth: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var shadowColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var shadowX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var shadowY: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var shadowBlur: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var startPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var startPointY: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var endPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var endPointY: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    #if TARGET_INTERFACE_BUILDER
        override open class var layerClass: AnyClass {
            return CAGradientLayer.self
        }

        override open func layoutSubviews() {
            if let gradientLayer = layer as? CAGradientLayer {
                gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
                gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
                gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
            }

            layer.cornerRadius = cornerRadius

            if borderWidth > 0 {
                layer.borderWidth = borderWidth
                layer.borderColor = borderColor.cgColor
            }

            if shadowBlur > 0 {
                layer.shadowColor = shadowColor.cgColor
                layer.shadowOffset = CGSize(width: shadowX, height: shadowY)
                layer.shadowRadius = shadowBlur
                layer.shadowOpacity = 1
                layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            }
        }

    #else

        override open func layoutSubviews() {
            super.layoutSubviews()

            if shadowBlur > 0 {
                var rect = bounds
                rect.origin.x += shadowX
                rect.origin.y += shadowY
                layer.shadowColor = shadowColor.cgColor
                layer.shadowOffset = CGSize(width: shadowX, height: shadowY)
                layer.shadowRadius = shadowBlur
                layer.shadowOpacity = 1
                layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
            }

            if bounds.size.width > 0, bounds.size.height > 0 {
                var image = UIImage.gradientImage(colors: [startColor, endColor],
                                                  size: bounds.size,
                                                  startPoint: CGPoint(x: startPointX, y: startPointY),
                                                  endPoint: CGPoint(x: endPointX, y: endPointY))

                image = UIImage.maskImageWithRoundedRect(image, cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor)
                layer.contents = image.cgImage
            }
        }
    #endif
}
