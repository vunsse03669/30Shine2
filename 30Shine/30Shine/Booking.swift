//
//  Booking.swift
//  30Shine
//
//  Created by Mr.Vu on 7/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation

class Booking: NSObject {
    
    var id : Int!
    var hour : String!
    var status : String!
    var slot : Int!
    var hourFrame : String!
    var salonId : Int!
    var currentSlot : Int!
    var stylistCurrentSlot : Int!
    
    
    init(id : Int, hour : String, status : String, slot : Int, hourFrame : String, salonId : Int, currentSlot : Int, stylistCurrentSlot : Int) {
        self.hour = hour
        self.status = status
        self.id = id
        self.slot = slot
        self.hourFrame = hourFrame
        self.salonId = salonId
        self.currentSlot = currentSlot
        self.stylistCurrentSlot = stylistCurrentSlot
    }
    
}
