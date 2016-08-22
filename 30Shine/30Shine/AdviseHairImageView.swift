//
//  AdviseHairImageView.swift
//  30Shine
//
//  Created by Apple on 8/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class AdviseHairImageView: UIView {

    @IBOutlet weak var imvModel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func createView(parentView : UIView) -> UIView {
        let adviseView = NSBundle.mainBundle().loadNibNamed("", owner: self, options: nil) [0] as! AdviseHairImageView
        let frame = CGRectMake(0, 110, parentView.frame.size.width, parentView.frame.size.width)
        adviseView.frame = frame
        parentView.addSubview(adviseView)
        
        return adviseView
    }
}
