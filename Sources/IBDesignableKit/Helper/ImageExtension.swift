//
//  ImageWithColor.swift
//  ToWatch
//
//  Created by PANGE on 2017/6/20.
//  Copyright © 2017年 PANGE. All rights reserved.
//

import UIKit

extension UIImage {
    static func maskImageWithRoundedRect(_ image: UIImage, cornerRadius: CGFloat,
                                         borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.white) -> UIImage
    {
        let imgRef = ImageUtils.CGImageWithCorrectOrientation(image)
        let size = CGSize(width: CGFloat(imgRef.width) / image.scale, height: CGFloat(imgRef.height) / image.scale)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        image.draw(in: rect)

        if borderWidth > 0 {
            context.setStrokeColor(borderColor.cgColor)
            context.setLineWidth(borderWidth)

            let borderRect = CGRect(x: 0, y: 0,
                                    width: size.width, height: size.height)

            let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius)
            borderPath.lineWidth = borderWidth * 2
            borderPath.stroke()
        }

        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    static func image(withColor color: UIColor, size: CGSize = CGSize(width: 1, height: 1), cornerRadius: CGFloat = 0) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if cornerRadius > 0 {
            let borderPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            borderPath.fill()
        } else {
            context.fill(rect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    static func imageAutoResized(withColor color: UIColor, cornerRadius: CGFloat) -> UIImage {
        let i = cornerRadius + 1
        let s = cornerRadius * 2 + 2
        let size = CGSize(width: s, height: s)
        let insets = UIEdgeInsets(top: i, left: i, bottom: i, right: i)
        let image = self.image(withColor: color, size: size, cornerRadius: cornerRadius)

        return image.resizableImage(withCapInsets: insets, resizingMode: UIImage.ResizingMode.stretch)
    }

    static func borderImage(withColor color: UIColor, cornerRadius: CGFloat, lineWidth: CGFloat) -> UIImage {
        let i = max(cornerRadius + 1, lineWidth + 1)
        let s1 = cornerRadius * 2 + 2
        let s2 = lineWidth * 2 + 2
        let s = max(s1, s2)
        let size = CGSize(width: s, height: s)
        let insets = UIEdgeInsets(top: i, left: i, bottom: i, right: i)

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(color.cgColor)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let borderPath = UIBezierPath(roundedRect: rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2), cornerRadius: cornerRadius)
        borderPath.lineWidth = lineWidth
        borderPath.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image.resizableImage(withCapInsets: insets, resizingMode: UIImage.ResizingMode.stretch)
    }

    static func borderImage(withColor color: UIColor, backgroundColor: UIColor, cornerRadius: CGFloat, lineWidth: CGFloat) -> UIImage {
        let i = max(cornerRadius + 1, lineWidth + 1)
        let s1 = cornerRadius * 2 + 2
        let s2 = lineWidth * 2 + 2
        let s = max(s1, s2)
        let size = CGSize(width: s, height: s)
        let insets = UIEdgeInsets(top: i, left: i, bottom: i, right: i)

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let borderPath = UIBezierPath(roundedRect: rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2), cornerRadius: cornerRadius)
        borderPath.lineWidth = lineWidth

        context.setStrokeColor(color.cgColor)
        borderPath.stroke()
        context.setFillColor(backgroundColor.cgColor)
        borderPath.fill()

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image.resizableImage(withCapInsets: insets, resizingMode: UIImage.ResizingMode.stretch)
    }

    static func circleImage(withColor color: UIColor, radius: CGFloat) -> UIImage {
        let size = CGSize(width: radius * 2, height: radius * 2)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.addEllipse(in: rect)
        context.fillPath()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

enum ImageUtils {
    static func CGImageWithCorrectOrientation(_ image: UIImage) -> CGImage {
        if image.imageOrientation == UIImage.Orientation.up {
            return image.cgImage!
        }

        var transform = CGAffineTransform.identity

        switch image.imageOrientation {
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: CGFloat(-1.0 * Double.pi / 2))
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        default:
            break
        }

        switch image.imageOrientation {
        case UIImage.Orientation.rightMirrored, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.downMirrored, UIImage.Orientation.upMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }

        let contextWidth: Int
        let contextHeight: Int

        switch image.imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored,
             UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            contextWidth = (image.cgImage?.height)!
            contextHeight = (image.cgImage?.width)!
        default:
            contextWidth = (image.cgImage?.width)!
            contextHeight = (image.cgImage?.height)!
        }

        let context = CGContext(data: nil, width: contextWidth, height: contextHeight,
                                bitsPerComponent: image.cgImage!.bitsPerComponent,
                                bytesPerRow: image.cgImage!.bytesPerRow,
                                space: image.cgImage!.colorSpace!,
                                bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!

        context.concatenate(transform)
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: CGFloat(contextWidth), height: CGFloat(contextHeight)))

        let cgImage = context.makeImage()
        return cgImage!
    }
}
