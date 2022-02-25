//
//  IBFirstResponderAction.swift
//  HJSwift
//
//  Created by PAN on 2017/11/10.
//  Copyright © 2017年 YR. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    @IBAction open func IBPopViewController() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction open func IBDismissViewController() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction open func IBPopViewControllerNoAnimated() {
        navigationController?.popViewController(animated: false)
    }

    @IBAction open func IBDismissViewControllerNoAnimated() {
        dismiss(animated: false, completion: nil)
    }

    @IBAction open func IBEndEditing() {
        view.endEditing(true)
    }
}
