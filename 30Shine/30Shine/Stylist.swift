//
//  Stylist.swift
//  30Shine
//
//  Created by Mr.Vu on 7/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation

class Stylist: NSObject {
    
    var id : Int!
    var fullName : String!
    var salonId : Int!
    
    init(id : Int, fullName : String, salonId : Int) {
        self.id = id
        self.fullName = fullName
        self.salonId = salonId
    }
    
}
