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