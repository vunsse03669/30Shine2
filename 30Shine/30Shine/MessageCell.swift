//
//  MessageCell.swift
//  30Shine
//
//  Created by Apple on 8/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderColor = UIColor.blackColor().CGColor
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.clipsToBounds = true
        self.lblNote.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        let f = contentView.frame
        let fr = UIEdgeInsetsInsetRect(f, UIEdgeInsetsMake(5, 20, 5, 20))
        contentView.frame = fr
    }

}
