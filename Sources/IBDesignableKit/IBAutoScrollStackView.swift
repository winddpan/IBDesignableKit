//
//  IBAutoScrollStackView.swift
//  IBDesignable
//
//  Created by PAN on 2021/9/23.
//

import Foundation
import UIKit

@IBDesignable
open class IBAutoScrollStackView: UIStackView, CAAnimationDelegate {
    @IBInspectable open var scrollInterval: TimeInterval = 5
    @IBInspectable open var animationDuration: TimeInterval = 0.3

    private var scrollTimer: Timer?
    private var stackSubviews: [UIView] = []
    private var redrawLayer: CALayer?

    override open func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            starScroll()
        } else {
            stopScroll()
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        stackSubviews = arrangedSubviews
    }

    override open func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)
        stackSubviews.append(view)
    }

    override open func removeArrangedSubview(_ view: UIView) {
        super.removeArrangedSubview(view)
        stackSubviews.removeAll(where: { $0 === view })
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        redrawLayer?.mask = nil
        redrawLayer?.removeAnimation(forKey: animKey)
        redrawLayer?.removeFromSuperlayer()
        redrawLayer = nil
    }
}

private extension IBAutoScrollStackView {
    var animKey: String {
        "scroll"
    }

    func scrollAnimation(fromView: UIView, toView: UIView) {
        redrawLayer?.removeFromSuperlayer()
        redrawLayer = fromView.layer

        // CATransformLayer masksToBounds 无效，使用子 layer mask 的方式解决问题
        fromView.layer.mask = nil
        toView.layer.mask = nil
        fromView.layer.removeAnimation(forKey: animKey)
        toView.layer.removeAnimation(forKey: animKey)

        fromView.removeFromSuperview()
        layer.addSublayer(fromView.layer)
        super.addArrangedSubview(toView)
        layoutIfNeeded()

        let fromAnmi: CABasicAnimation
        let toAnmi: CABasicAnimation
        switch axis {
        case .horizontal:
            fromAnmi = CABasicAnimation(keyPath: "transform.translation.x")
            fromAnmi.fromValue = 0
            fromAnmi.toValue = -toView.frame.width - spacing
            fromAnmi.duration = animationDuration
            fromAnmi.repeatCount = 1
            fromAnmi.fillMode = .forwards
            fromAnmi.isRemovedOnCompletion = false

            toAnmi = fromAnmi.copy() as! CABasicAnimation
            toAnmi.fromValue = toView.frame.width + spacing
            toAnmi.toValue = 0
        case .vertical:
            fromAnmi = CABasicAnimation(keyPath: "transform.translation.y")
            fromAnmi.fromValue = 0
            fromAnmi.toValue = -toView.frame.height - spacing
            fromAnmi.duration = animationDuration
            fromAnmi.repeatCount = 1
            fromAnmi.fillMode = .forwards
            fromAnmi.isRemovedOnCompletion = false

            toAnmi = fromAnmi.copy() as! CABasicAnimation
            toAnmi.fromValue = toView.frame.height + spacing
            toAnmi.toValue = 0
        @unknown default:
            return
        }

        let fromMask = CALayer()
        fromMask.backgroundColor = UIColor.black.cgColor
        fromMask.frame = fromView.bounds
        fromView.layer.mask = fromMask

        let toMask = CALayer()
        toMask.backgroundColor = UIColor.black.cgColor
        toMask.frame = toView.bounds
        toView.layer.mask = toMask

        let maskFromAnim = fromAnmi.copy() as! CABasicAnimation
        maskFromAnim.fromValue = 0
        maskFromAnim.toValue = -(fromAnmi.toValue as! CGFloat)

        let maskToAnim = toAnmi.copy() as! CABasicAnimation
        maskToAnim.fromValue = -(toAnmi.fromValue as! CGFloat)
        maskToAnim.toValue = 0

        fromAnmi.delegate = self
        fromView.layer.add(fromAnmi, forKey: animKey)
        fromMask.add(maskFromAnim, forKey: animKey)

        toView.layer.add(toAnmi, forKey: animKey)
        toMask.add(maskToAnim, forKey: animKey)
    }

    func starScroll() {
        stopScroll()
        guard stackSubviews.count > 1 else { return }
        if arrangedSubviews.count > 1 {
            stackSubviews.enumerated().forEach { idx, view in
                view.layer.transform = CATransform3DIdentity
                if idx == 0 {
                    super.addArrangedSubview(view)
                } else {
                    view.removeFromSuperview()
                }
            }
        }
        scrollTimer = Timer.scheduledTimer(withTimeInterval: scrollInterval, repeats: true, block: { [weak self] _ in
            if let self = self, self.stackSubviews.count > 1, let firstView = self.arrangedSubviews.first, let currIdx = self.stackSubviews.firstIndex(of: firstView) {
                let nextIdx = self.stackSubviews.count > currIdx + 1 ? currIdx + 1 : 0
                self.scrollAnimation(fromView: self.stackSubviews[currIdx], toView: self.stackSubviews[nextIdx])
            }
        })
    }

    func stopScroll() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
}
