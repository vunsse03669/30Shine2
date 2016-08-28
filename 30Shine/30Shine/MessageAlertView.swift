//
//  MessageAlertView.swift
//  30Shine
//
//  Created by Apple on 8/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


protocol MessageAlertProtocol {
    func changeColor()
}

class MessageAlertView: UIView {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvIcon: UIImageView!
    
    var delegate : MessageAlertProtocol!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tappedBtnClose()
    }
    
    static func createView(superView : UIView, title : String, time : String, imagePath : String, content : String) -> MessageAlertView!  {
        let messageView = NSBundle.mainBundle().loadNibNamed("MessageAlertView", owner: self, options: nil) [0] as! MessageAlertView
        messageView.lblTitle.sizeToFit()
        let height = messageView.lblTitle.frame.size.height + messageView.btnClose.frame.size.height + messageView.lblText.frame.height + messageView.lblTime.frame.size.height + 60
        let width = 4*superView.frame.width/5
        let dx = (superView.frame.size.width - width)/2
        let dy = superView.frame.size.height/2 - height
        let frame = CGRectMake(dx, dy, width, height)
        messageView.frame = frame
        
        messageView.lblTitle.text = title
        messageView.lblTime.text = time
        messageView.lblText.text = content
        messageView.imvIcon.image = UIImage(named: imagePath)
        
        superView.addSubview(messageView)
        
        return messageView
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
