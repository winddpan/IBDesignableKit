//
//  IBMasksView.swift
//  HJSwift
//
//  Created by PAN on 2018/11/23.
//  Copyright © 2018 YR. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class IBCornerRadiusMasksView: UIView {
    @IBInspectable public var cornerRadius: CGFloat = 0.0 {
        didSet {
            if cornerRadius != oldValue {
                setNeedsLayout()
            }
        }
    }

    @IBInspectable public var maskTopLeft: Bool = true {
        didSet {
            if maskTopLeft != oldValue {
                setNeedsLayout()
            }
        }
    }

    @IBInspectable public var maskTopRight: Bool = true {
        didSet {
            if maskTopRight != oldValue {
                setNeedsLayout()
            }
        }
    }

    @IBInspectable public var maskBottomLeft: Bool = true {
        didSet {
            if maskBottomLeft != oldValue {
                setNeedsLayout()
            }
        }
    }

    @IBInspectable public var maskBottomRight: Bool = true {
        didSet {
            if maskBottomRight != oldValue {
                setNeedsLayout()
            }
        }
    }

    override open func layoutSubviews() {
        layer.masksToBounds = true

        if cornerRadius <= 0 {
            layer.mask = nil
        } else {
            let currentFrame = bounds
            let radius = cornerRadius
            let path = CGMutablePath()

            // Points - Eight points that define the round border. Each border is defined by two points.
            let topLeftPoint = CGPoint(x: radius, y: 0)
            let topRightPoint = CGPoint(x: currentFrame.size.width - radius, y: 0)
            let middleRightBottomPoint = CGPoint(x: currentFrame.size.width, y: currentFrame.size.height - radius)
            let bottomLeftPoint = CGPoint(x: radius, y: currentFrame.size.height)
            let middleLeftTopPoint = CGPoint(x: 0, y: radius)

            // Points - Four points that are the center of the corners borders.
            let cornerTopRightCenter = CGPoint(x: currentFrame.size.width - radius, y: radius)
            let cornerBottomRightCenter = CGPoint(x: currentFrame.size.width - radius, y: currentFrame.size.height - radius)
            let cornerBottomLeftCenter = CGPoint(x: radius, y: currentFrame.size.height - radius)
            let cornerTopLeftCenter = CGPoint(x: radius, y: radius)

            // Angles - The corner radius angles.
            let topRightStartAngle = CGFloat(Double.pi * 3 / 2)
            let topRightEndAngle = CGFloat(0)
            let bottomRightStartAngle = CGFloat(0)
            let bottmRightEndAngle = CGFloat(Double.pi / 2)
            let bottomLeftStartAngle = CGFloat(Double.pi / 2)
            let bottomLeftEndAngle = CGFloat(Double.pi)
            let topLeftStartAngle = CGFloat(Double.pi)
            let topLeftEndAngle = CGFloat(Double.pi * 3 / 2)

            // Vertex
            let topLeftVertex = CGPoint(x: 0, y: 0)
            let topRightVertex = CGPoint(x: currentFrame.maxX, y: 0)
            let bottomLeftVertex = CGPoint(x: 0, y: currentFrame.maxY)
            let bottomRightVertex = CGPoint(x: currentFrame.maxX, y: currentFrame.maxY)

            // Drawing a border around a view.
            path.move(to: topLeftPoint)
            path.addLine(to: topRightPoint)

            if maskTopRight {
                path.addArc(center: cornerTopRightCenter,
                            radius: radius,
                            startAngle: topRightStartAngle,
                            endAngle: topRightEndAngle,
                            clockwise: false)
            } else {
                path.addLine(to: topRightVertex)
            }
            path.addLine(to: middleRightBottomPoint)

            if maskBottomRight {
                path.addArc(center: cornerBottomRightCenter,
                            radius: radius,
                            startAngle: bottomRightStartAngle,
                            endAngle: bottmRightEndAngle,
                            clockwise: false)
            } else {
                path.addLine(to: bottomRightVertex)
            }
            path.addLine(to: bottomLeftPoint)

            if maskBottomLeft {
                path.addArc(center: cornerBottomLeftCenter,
                            radius: radius,
                            startAngle: bottomLeftStartAngle,
                            endAngle: bottomLeftEndAngle,
                            clockwise: false)
            } else {
                path.addLine(to: bottomLeftVertex)
            }
            path.addLine(to: middleLeftTopPoint)

            if maskTopLeft {
                path.addArc(center: cornerTopLeftCenter,
                            radius: radius,
                            startAngle: topLeftStartAngle,
                            endAngle: topLeftEndAngle,
                            clockwise: false)
            } else {
                path.addLine(to: topLeftVertex)
                path.addLine(to: topLeftPoint)
            }

            let maskLayer = CAShapeLayer()
            maskLayer.frame = layer.bounds
            maskLayer.path = path
            layer.mask = maskLayer
        }
        super.layoutSubviews()
    }
}
