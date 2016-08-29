//
//  MenuCell.swift
//  30Shine
//
//  Created by Mr.Vu on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class MenuCell: UICollectionViewCell {
    
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var imvMenu: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblNote.layer.cornerRadius = self.lblNote.frame.size.height/2
        self.lblNote.clipsToBounds = true
        self.lblNote.hidden = true
    }
}
