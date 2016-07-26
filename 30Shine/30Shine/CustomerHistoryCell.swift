//
//  CustomerHistoryCellTableViewCell.swift
//  30Shine
//
//  Created by Mr.Vu on 7/23/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class CustomerHistoryCell: UITableViewCell {
    @IBOutlet weak var lblService: UILabel!
    @IBOutlet weak var lblStylist: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblHour: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 13
        self.contentView.clipsToBounds = true
        self.contentView.backgroundColor = UIColor(netHex: 0xDBDDDE)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        let f = contentView.frame
        let fr = UIEdgeInsetsInsetRect(f, UIEdgeInsetsMake(10, 10, 10, 10))
        contentView.frame = fr
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
