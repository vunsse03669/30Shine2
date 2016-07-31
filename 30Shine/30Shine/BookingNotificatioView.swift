//
//  BookingNotificatioView.swift
//  30Shine
//
//  Created by Mr.Vu on 7/31/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BookingNotificatioView: UIView {
    
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var isCheck = false
    var notification : BookingNotification!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        if BookingNotification.getNotificationById(1) == nil {
            self.notification = BookingNotification.create(1, showMessage: 1)
        }
        else {
            self.notification = BookingNotification.getNotificationById(1)
        }

        
        _ = btnCheckBox.rx_tap.subscribeNext {
            self.isCheck = !self.isCheck
            if self.isCheck {
                self.btnCheckBox.setImage(UIImage(named: "img-checked"), forState: .Normal)
            }
            else {
                self.btnCheckBox.setImage(UIImage(named: "img-unchecked"), forState: .Normal)
            }
        }
        
        _ = btnConfirm.rx_tap.subscribeNext {
           
            if self.isCheck {
                BookingNotification.updateMessage(self.notification, message: 0)
            }
            UIView.animateWithDuration(0.2, animations: { 
                self.alpha = 0
                }, completion: { (animate) in
                    self.removeFromSuperview()
            })
            
        }
    }
    
    func configUI() {
        self.btnConfirm.layer.cornerRadius = 5.0
        self.layer.shadowColor = UIColor.grayColor().CGColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSizeZero
        self.layer.shadowRadius = 5
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    
    static func createView(view : UIView) -> BookingNotificatioView! {
        let frame = CGRectMake(0, 66,view.bounds.width, view.bounds.height)
        let bookingView = NSBundle.mainBundle().loadNibNamed("BookingNotificationView", owner: self, options: nil)[0] as! BookingNotificatioView
        bookingView.frame = frame
        bookingView.layer.zPosition = 1000
        if BookingNotification.getNotificationById(1).showMessage == 1 {
            view.addSubview(bookingView)
            view.bringSubviewToFront(bookingView)
        }
        
        bookingView.alpha = 0
        UIView .animateWithDuration(0.2) {
            bookingView.alpha = 1
        }
        
        return bookingView
    }
    
}
