//
//  ForgetAlertView.swift
//  30Shine
//
//  Created by Apple on 8/27/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol ForgetAlertProtocol {
    func changeColor()
}

class ForgetAlertView: UIView {
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    var delegate : ForgetAlertProtocol!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tappedBtnClose()
    }
    
    static func createView(superView : UIView, msg : String) -> ForgetAlertView!  {
        let forgetView = NSBundle.mainBundle().loadNibNamed("ForgetAlertView", owner: self, options: nil) [0] as! ForgetAlertView
        forgetView.lblTitle.sizeToFit()
        let height = forgetView.lblTitle.frame.size.height + forgetView.btnClose.frame.size.height + 60
        let width = 4*superView.frame.width/5
        let dx = (superView.frame.size.width - width)/2
        let dy = superView.frame.size.height/2 - height
        let frame = CGRectMake(dx, dy, width, height)
        forgetView.frame = frame
        forgetView.lblTitle.text = msg
        superView.addSubview(forgetView)
        
        return forgetView
    }
    
    func tappedBtnClose() {
        _ = self.btnClose.rx_tap.subscribeNext {
            self.removeFromSuperview()
            if self.delegate != nil {
                self.delegate.changeColor()
            }
        }
    }
    
    
}
