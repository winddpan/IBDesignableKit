//
//  IBImageView.swift
//  HJSwift
//
//  Created by PAN on 2017/10/16.
//  Copyright © 2017年 YR. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class IBImageView: UIImageView {
    private var rawImage: UIImage?
    private var renderedImage: UIImage?
    private var redrawToken: String?
    private var runloopTaskToken: UUID?

    @IBInspectable
    public var cornerRadius: CGFloat = 0 {
        didSet {
            if cornerRadius != oldValue { setNeedsRender() }
        }
    }

    @IBInspectable
    public var borderWidth: CGFloat = 0 {
        didSet {
            if borderWidth != oldValue { setNeedsRender() }
        }
    }

    @IBInspectable
    public var borderColor: UIColor = .clear {
        didSet {
            if borderColor != oldValue { setNeedsRender() }
        }
    }

    @IBInspectable
    public var imageBackgroundColor: UIColor = .clear {
        didSet {
            if imageBackgroundColor != oldValue { setNeedsRender() }
        }
    }

    override public var contentMode: UIView.ContentMode {
        didSet {
            if contentMode != oldValue { setNeedsRender() }
        }
    }

    override public var image: UIImage? {
        set {
            guard newValue !== rawImage else {
                return
            }
            rawImage = newValue

            if rawImage == nil {
                renderImage(nil)
            } else {
                setNeedsRender()
            }
        }
        get {
            return renderedImage
        }
    }

    private var imageStyle = IBImageStyle()

    private func renderImage(_ image: UIImage?) {
        renderedImage = image
        super.image = image
    }

    deinit {
        IBImageCache.shared.removeObject(forKey: imageStyle.token)
    }

    private func setNeedsRender() {
        if let oldRedrawToken = redrawToken {
            AsyncDrawer.shared.cancelRedraw(oldRedrawToken)
            redrawToken = nil
        }

        // xib里面设置了image，重新绘制
        if rawImage == nil, super.image != nil {
            rawImage = super.image
            renderImage(nil)
        }
        if rawImage == nil {
            renderImage(nil)
        } else {
            var newStyle = IBImageStyle()
            newStyle.bounds = bounds
            newStyle.contentMode = contentMode
            newStyle.borderColor = borderColor
            newStyle.borderWidth = max(0, borderWidth)
            newStyle.cornerRadius = max(0, cornerRadius)
            newStyle.imageBackgroundColor = imageBackgroundColor
            newStyle.rawImage = rawImage
            imageStyle = newStyle

            let drawToken = imageStyle.token
            let taskToken = UUID()
            runloopTaskToken = taskToken

            // draw on next runloop
            OperationQueue.main.addOperation {
                if self.runloopTaskToken == taskToken, self.imageStyle.token == drawToken {
                    self.IBUpdateImage(self.imageStyle)
                }
            }
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if imageStyle.bounds != bounds {
            imageStyle.bounds = bounds
            setNeedsRender()
        }
    }

    private func IBUpdateImage(_ imageStyle: IBImageStyle) {
        if imageStyle.rawImage == nil || rawImage == nil {
            renderImage(nil)
            return
        }
        if imageStyle.cornerRadius == 0, imageStyle.borderWidth == 0 {
            renderImage(rawImage)
            return
        }
        if imageStyle.bounds.size == .zero {
            return
        }

        #if TARGET_INTERFACE_BUILDER
            let image = imageStyle.redraw()
            renderImage(image)
        #else
            if let cacheImage = IBImageCache.shared.object(forKey: imageStyle.token) {
                renderImage(cacheImage)
            } else {
                renderImage(nil)
                redrawToken = AsyncDrawer.shared.redraw(imageStyle, completion: { [weak self] drawStyle, newImage in
                    if let self = self, self.imageStyle.token == drawStyle.token {
                        IBImageCache.shared.setObject(newImage, forKey: drawStyle.token, cost: Int(newImage.size.height * newImage.size.width))
                        self.renderImage(newImage)
                    }
                })
            }
        #endif
    }
}

private enum IBImageViewLayout {
    static func frameForImageWithSize(_ image: CGSize, inContainerWithSize container: CGSize, usingContentMode contentMode: UIView.ContentMode) -> CGRect {
        let size = sizeForImage(image, container: container, contentMode: contentMode)
        let position = positionForImage(size, container: container, contentMode: contentMode)

        return CGRect(origin: position, size: size)
    }

    private static func sizeForImage(_ image: CGSize, container: CGSize, contentMode: UIView.ContentMode) -> CGSize {
        switch contentMode {
        case .scaleToFill:
            return container
        case .scaleAspectFit:
            let heightRatio = imageHeightRatio(image, container: container)
            let widthRatio = imageWidthRatio(image, container: container)
            return scaledImageSize(image, ratio: max(heightRatio, widthRatio))
        case .scaleAspectFill:
            let heightRatio = imageHeightRatio(image, container: container)
            let widthRatio = imageWidthRatio(image, container: container)
            return scaledImageSize(image, ratio: min(heightRatio, widthRatio))
        case .redraw:
            return container
        default:
            return image
        }
    }

    private static func positionForImage(_ image: CGSize, container: CGSize, contentMode: UIView.ContentMode) -> CGPoint {
        switch contentMode {
        case .scaleToFill:
            return .zero
        case .scaleAspectFit:
            return CGPoint(x: (container.width - image.width) / 2, y: (container.height - image.height) / 2)
        case .scaleAspectFill:
            return CGPoint(x: (container.width - image.width) / 2, y: (container.height - image.height) / 2)
        case .redraw:
            return .zero
        case .center:
            return CGPoint(x: (container.width - image.width) / 2, y: (container.height - image.height) / 2)
        case .top:
            return CGPoint(x: (container.width - image.width) / 2, y: 0)
        case .bottom:
            return CGPoint(x: (container.width - image.width) / 2, y: container.height - image.height)
        case .left:
            return CGPoint(x: 0, y: (container.height - image.height) / 2)
        case .right:
            return CGPoint(x: container.width - image.width, y: (container.height - image.height) / 2)
        case .topLeft:
            return .zero
        case .topRight:
            return CGPoint(x: container.width - image.width, y: 0)
        case .bottomLeft:
            return CGPoint(x: 0, y: container.height - image.height)
        case .bottomRight:
            return CGPoint(x: container.width - image.width, y: container.height - image.height)
        @unknown default:
            return CGPoint(x: 0, y: 0)
        }
    }

    private static func imageHeightRatio(_ image: CGSize, container: CGSize) -> CGFloat {
        return image.height / container.height
    }

    private static func imageWidthRatio(_ image: CGSize, container: CGSize) -> CGFloat {
        return image.width / container.width
    }

    private static func scaledImageSize(_ image: CGSize, ratio: CGFloat) -> CGSize {
        return CGSize(width: image.width / ratio, height: image.height / ratio)
    }
}

private class IBImageCache: NSCache<NSString, UIImage> {
    public static let shared: IBImageCache = {
        let cache = IBImageCache()
        cache.name = "IBImageCache"
        cache.totalCostLimit = 1024 * 1024 * 64
        return cache
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(memoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    @objc open func memoryWarning() {
        removeAllObjects()
    }
}

private struct IBImageStyle {
    var cornerRadius: CGFloat = 0
    var borderWidth: CGFloat = 0
    var borderColor: UIColor = .clear
    var imageBackgroundColor: UIColor = .clear
    var contentMode: UIView.ContentMode = .scaleToFill
    var bounds: CGRect = .zero
    var rawImage: UIImage?

    var token: NSString {
        var hash = "\(cornerRadius)_\(borderWidth)_\(borderColor)_\(imageBackgroundColor)_\(contentMode.rawValue)_\(bounds)"
        if let rawImage = rawImage {
            let rawImagePointer = Unmanaged.passUnretained(rawImage as AnyObject).toOpaque()
            hash += "_\(rawImagePointer.hashValue)"
        }
        return NSString(string: hash)
    }

    func redraw() -> UIImage? {
        if let rawImage = rawImage {
            return drawImage(rawImage)
        }
        return nil
    }

    private func drawImage(_ rawImage: UIImage) -> UIImage? {
        guard bounds.width > 0, bounds.height > 0 else { return nil }

        func drawInContext(_ context: CGContext) {
            let frame = IBImageViewLayout.frameForImageWithSize(rawImage.size, inContainerWithSize: bounds.size, usingContentMode: contentMode)
            if frame.size.width > 0, frame.size.height > 0 {
                if borderWidth > 0 {
                    context.setFillColor(borderColor.cgColor)
                    let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
                    path.fill()
                }

                context.setFillColor(imageBackgroundColor.cgColor)
                let path = UIBezierPath(roundedRect: bounds.insetBy(dx: borderWidth, dy: borderWidth), cornerRadius: cornerRadius)
                path.fill()

                let w = CGFloat.maximum(borderWidth, 0)
                context.addPath(UIBezierPath(roundedRect: bounds.insetBy(dx: w, dy: w), cornerRadius: cornerRadius).cgPath)
                context.clip()
                rawImage.draw(in: frame)
            }
        }

        var resultImage: UIImage?
        if #available(iOS 10.0, *) {
            autoreleasepool {
                let render = UIGraphicsImageRenderer(bounds: bounds)
                let image = render.image { renderContext in
                    let context = renderContext.cgContext
                    drawInContext(context)
                }
                resultImage = image
            }
        } else {
            autoreleasepool {
                UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
                if let context = UIGraphicsGetCurrentContext() {
                    drawInContext(context)
                    let image = UIGraphicsGetImageFromCurrentImageContext()
                    resultImage = image
                }
                UIGraphicsEndImageContext()
            }
        }
        return resultImage
    }
}

private class AsyncDrawer {
    static let shared = AsyncDrawer()
    private let asyncQueue = OperationQueue()
    private var toDrawTokens: [String: BlockOperation] = [:]
    private let lock = NSLock()

    init() {
        asyncQueue.maxConcurrentOperationCount = 4
    }

    func cancelRedraw(_ token: String) {
        lock.lock()
        toDrawTokens[token]?.cancel()
        toDrawTokens.removeValue(forKey: token)
        lock.unlock()
    }

    func redraw(_ imageStyle: IBImageStyle, completion: @escaping (IBImageStyle, UIImage) -> Void) -> String {
        let drawToken = UUID().uuidString
        let operaion = BlockOperation {
            self.lock.lock()
            guard let op = self.toDrawTokens[drawToken], !op.isCancelled else {
                self.lock.unlock()
                return
            }
            self.lock.unlock()

            var newImage: UIImage?
            if let image = imageStyle.redraw() {
                newImage = image
            }

            self.lock.lock()
            self.toDrawTokens.removeValue(forKey: drawToken)
            self.lock.unlock()

            if let newImage = newImage {
                OperationQueue.main.addOperation {
                    completion(imageStyle, newImage)
                }
            }
        }

        lock.lock()
        toDrawTokens[drawToken] = operaion
        lock.unlock()
        asyncQueue.addOperation(operaion)

        return drawToken
    }
}
