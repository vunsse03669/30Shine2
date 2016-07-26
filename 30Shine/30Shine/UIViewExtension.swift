//
//  UIViewExtension.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func fadeIn(time: NSTimeInterval){
        self.alpha = 0
        UIView .animateWithDuration(time) { 
            self.alpha = 1
        }
    }
    
    func fadeOut(time: NSTimeInterval){
        self.alpha = 1
        UIView.animateWithDuration(time) { 
            self.alpha = 0
        }
    }
}
