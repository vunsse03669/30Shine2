//
//  MenuCell.swift
//  30Shine
//
//  Created by Mr.Vu on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class MenuCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvMenu: UIImageView!
    
    override func awakeFromNib() {
        lblTitle.sizeToFit()
        lblTitle.numberOfLines = 0
        imvMenu.layer.cornerRadius = 13.0
        self.imvMenu.clipsToBounds = true
    }
}
