//
//  File.swift
//  
//
//  Created by PAN on 2022/2/25.
//

import Foundation

extension DispatchQueue {
    class func _onMainThread(_ task: @escaping () -> Void) {
        if Thread.isMainThread {
            task()
        } else {
            DispatchQueue.main.async {
                task()
            }
        }
    }
}
