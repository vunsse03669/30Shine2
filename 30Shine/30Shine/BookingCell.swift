//
//  BookingCell.swift
//  30Shine
//
//  Created by Mr.Vu on 7/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class BookingCell: UICollectionViewCell {
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    var canBooking = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        self.backgroundColor = UIColor.grayColor()
    }

}
