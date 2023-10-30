//
//  UIView+JFSnapShot.swift
//  JRBaseKit
//
//  Created by JerryFans on 2023/10/8.
//

import UIKit

public extension UIView {
    @objc func jf_syncSnapshotImage() -> UIImage? {
        return self.jf.syncSnapshotImage()
    }
    
    @objc func jf_syncSnapshotImage(scale:CGFloat) -> UIImage? {
        return self.jf.syncSnapshotImage(scale: scale)
    }
}

public extension JF where Base: UIView {
    
    func removeAllSubviews() {
        while (base.subviews.count != 0) {
            base.subviews.last?.removeFromSuperview()
        }
    }
    
    func syncSnapshotImage() -> UIImage? {
        return base.jf.syncSnapshotImage(scale: UIScreen.main.scale)
    }
    
    func syncSnapshotImage(scale:CGFloat) -> UIImage? {
        if base.bounds.size == .zero {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(base.bounds.size, false, scale);
        let snapshotImage:UIImage? = {
            guard let currentContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            base.layer.render(in: currentContext)
            return UIGraphicsGetImageFromCurrentImageContext()
        }()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
}
