//
//  ViewControllerExtension.swift
//  30Shine
//
//  Created by Mr.Vu on 7/29/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func isLogin() -> Bool {
        return Login.getLogin() != nil
    }
}