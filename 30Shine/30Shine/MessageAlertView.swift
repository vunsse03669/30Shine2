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
    @IBOutlet weak var imvImage: UIImageView!
    
    var delegate : MessageAlertProtocol!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tappedBtnClose()
    }
    
    static func createView(superView : UIView, title : String, time : String,iconPath: String, imagePath : String, content : String) -> MessageAlertView!  {
        let messageView = NSBundle.mainBundle().loadNibNamed("MessageAlertView", owner: self, options: nil) [0] as! MessageAlertView
        messageView.lblTitle.sizeToFit()
        
        let frame1 = CGRectMake(0, 600, superView.frame.size.width, superView.frame.size.height)
        messageView.frame = frame1
        
        messageView.lblTitle.text = title
        messageView.lblTime.text = time
        messageView.lblText.text = content
        
        
       // messageView.lblText.sizeToFit()
        messageView.lblTime.sizeToFit()
        messageView.lblTime.sizeToFit()
        
        var sizeImage = CGFloat(230)
    
        if imagePath.isEmpty {
            
            sizeImage = 100
        }
        
        UIView.animateWithDuration(0.3) { 
            let height = messageView.lblTitle.frame.size.height + messageView.btnClose.frame.size.height + messageView.lblText.frame.height + messageView.lblTime.frame.size.height + sizeImage
            let width = 4*superView.frame.width/5
            let dx = (superView.frame.size.width - width)/2
            let dy = CGFloat(100.0) //superView.frame.size.height/2 - height/2
            let frame = CGRectMake(dx, dy, width, height)
            messageView.frame = frame
        }
        
        LazyImage.showForImageView(messageView.imvImage, url: imagePath, defaultImage: "")
        if !imagePath.isEmpty {
            messageView.imvImage.frame = CGRectMake(0, 0, 0, 0)
        }
        messageView.imvIcon.image = UIImage(named: iconPath)
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
