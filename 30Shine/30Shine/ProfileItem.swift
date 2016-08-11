//
//  ProfileItem.swift
//  30Shine
//
//  Created by Apple on 8/11/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class ProfileItem: NSObject {
    var title : String!
    var imagePath : String!
    
    init(title : String, imagePath : String) {
        self.title = title
        self.imagePath = imagePath
    }
}
