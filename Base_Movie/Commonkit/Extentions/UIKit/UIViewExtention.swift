//
//  UIViewExtention.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import UIKit

extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
}

extension UIView {
    
    class func loadXibView<T: UIView>(fromNib viewType: T.Type, owner: Any?) -> UIView? {
        let nibName = String(describing: viewType)
        let nib = UINib.init(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: owner, options: nil)[0] as? UIView
    }
}

extension UIView{
    
    private static let kRotationAnimationKey = "transform.rotation.z"
    
    func rotate(duration: Double = 1) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: UIView.kRotationAnimationKey)
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
}
