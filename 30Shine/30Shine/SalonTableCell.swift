//
//  SalonTableCell.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class SalonTableCell: UITableViewCell {

    @IBOutlet weak var imvSalon: UIImageView!
    @IBOutlet weak var lblAdress: UILabel!
    @IBOutlet weak var lblManager: UILabel!
    @IBOutlet weak var lblHotLine: UILabel!
    @IBOutlet weak var lblFacebookLink: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
