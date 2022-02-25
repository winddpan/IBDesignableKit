//
//  GradientImage.swift
//  HJSwift
//
//  Created by PAN on 2017/8/29.
//  Copyright © 2017年 YR. All rights reserved.
//

import UIKit

enum GradientImageMode {
    case horizontal
    case vertical
}

extension UIImage {
    class func gradientImage(colors: [UIColor],
                             size: CGSize,
                             locations: [Float] = [],
                             startPoint: CGPoint,
                             endPoint: CGPoint) -> UIImage
    {
        // start with a CAGradientLayer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: size)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint

        if !locations.isEmpty {
            gradientLayer.locations = locations.map { NSNumber(value: $0) }
        }

        // now build a UIImage from the gradient
        UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, false, 0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // return the gradient image
        return gradientImage
    }

    class func gradientImage(colors: [UIColor],
                             size: CGSize,
                             locations: [Float] = [],
                             mode: GradientImageMode) -> UIImage
    {
        var startPoint: CGPoint!
        var endPoint: CGPoint!

        switch mode {
        case .horizontal:
            startPoint = CGPoint(x: 0, y: 0.5)
            endPoint = CGPoint(x: 1, y: 0.5)
        case .vertical:
            startPoint = CGPoint(x: 0.5, y: 0)
            endPoint = CGPoint(x: 0.5, y: 1)
        }

        return gradientImage(colors: colors, size: size, locations: locations, startPoint: startPoint, endPoint: endPoint)
    }
}
