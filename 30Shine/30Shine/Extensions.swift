//
//  Extensions.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/31/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import UIKit
extension UINavigationController{
    func push(viewController : UIViewController, animated : Bool){
        self.pushViewController(viewController, animated: true)
    }
    
    func pop(){
        
        let viewControllers: [UIViewController] = self.viewControllers as [UIViewController];
        for vc in viewControllers {
            self.popToViewController(vc, animated: true)
        }
    }
}

extension UIView {
    func bounceAction(completion:()->()){
        UIView.animateWithDuration(0.1, animations: {
            self.transform = CGAffineTransformMakeScale(0.95, 0.95)
        }) { (Bool) in
            UIView.animateWithDuration(0.1, animations: {
                self.transform = CGAffineTransformIdentity
                }, completion: { (bool) in
                    completion()
            })
        }
    }
    
    func flyInLR(completion:()->()){
        let originnalX = self.frame.origin.x
        self.frame.origin.x = -400
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            self.frame.origin.x = originnalX
        }) { (bool) in
            completion()
        }
    }
    
    func flyOutLR(completion:()->()){
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            self.frame.origin.x = 0
        }) { (bool) in
            completion()
        }

    }
    
    func flyInRL(completion:()->()){
        let originnalX = self.frame.origin.x
        self.frame.origin.x = 400
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            self.frame.origin.x = originnalX
        }) { (bool) in
            completion()
        }
    }
    
    func flyOutRL(completion:()->()){
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            self.frame.origin.x = -400
        }) { (bool) in
            completion()
        }
    }
}

extension UILabel {
    func mutiColor(originalString : String,startAt:Int, range: Int , color: UIColor){
        if(startAt >= originalString.length || startAt < 0 || range < 0)
        {
            return
        }
        let range = NSRange(location:startAt,length:range)
        let attributedString = NSMutableAttributedString(string: originalString)
        attributedString.addAttribute(NSForegroundColorAttributeName,value: color, range: range)
        self.attributedText = attributedString
    }
}

extension UIButton {
    func customButton() {
//        let spacing: CGFloat = 0.0
//        let imageSize: CGSize = self.imageView!.image!.size
//        self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height + spacing), 0.0)
//        let labelString = NSString(string: self.titleLabel!.text!)
//        let titleSize = labelString.sizeWithAttributes([NSFontAttributeName: self.titleLabel!.font])
//        self.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, -titleSize.width)
//        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
//        self.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset, 0.0, edgeOffset, 0.0)
//        self.titleLabel?.font = UIFont.systemFontOfSize(8)
        
        self.imageView?.contentMode = .ScaleAspectFit
    }
}