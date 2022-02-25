//
//  IBProgressView.swift
//  HJSwift
//
//  Created by PAN on 2018/11/22.
//  Copyright © 2018 YR. All rights reserved.
//

import UIKit

@IBDesignable
open class IBProgressView: UIView {
    @IBInspectable open var progress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var progressTintColor: UIColor = .blue {
        didSet {
            progressLayer.backgroundColor = progressTintColor.cgColor
        }
    }

    @IBInspectable open var trackTintColor: UIColor = .clear {
        didSet {
            trackLayer.backgroundColor = trackTintColor.cgColor
        }
    }

    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
            trackLayer.cornerRadius = cornerRadius
            trackLayer.masksToBounds = cornerRadius > 0
            progressLayer.cornerRadius = cornerRadius
            progressLayer.masksToBounds = cornerRadius > 0
        }
    }

    private let trackLayer = CALayer()
    private let progressLayer = CALayer()

    open func setProgress(_ progress: CGFloat, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.progress = progress
            }
        } else {
            self.progress = progress
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        clipsToBounds = true
        backgroundColor = .clear

        if trackLayer.superlayer == nil {
            layer.insertSublayer(trackLayer, at: 0)
        }
        if progressLayer.superlayer == nil {
            layer.insertSublayer(progressLayer, at: 1)
        }
        if bounds.width > 0, bounds.height > 0 {
            trackLayer.frame = bounds
            if progress >= 0 {
                progressLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
            }
        }
    }
}
