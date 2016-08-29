//
//  ProfileItemCell.swift
//  30Shine
//
//  Created by Apple on 8/11/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class ProfileItemCell: UITableViewCell {
    @IBOutlet weak var lblNumberMessage: UILabel!
    @IBOutlet weak var imvImage: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblNumberMessage.layer.cornerRadius = lblNumberMessage.frame.size.height/2
        lblNumberMessage.clipsToBounds = true
        lblNumberMessage.hidden = true
    }
    
}
