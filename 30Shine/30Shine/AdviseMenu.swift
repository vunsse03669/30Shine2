//
//  AdviseMenu.swift
//  30Shine
//
//  Created by Apple on 8/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class AdviseMenu: NSObject {
    
    var title : String!
    var descreption : String!
    var imagePath : String!
    
    init(title : String, descreption : String, imagePath : String) {
        self.title = title
        self.descreption = descreption
        self.imagePath = imagePath
    }

}
