//
//  Video.swift
//  30Shine
//
//  Created by Mr.Vu on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation

class Video: NSObject {
    var thumnailUrl : String!
    var title       : String!
    
    init(title : String, thumb : String) {
        self.title = title
        self.thumnailUrl = thumb
    }
}
