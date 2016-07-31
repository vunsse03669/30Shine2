//
//  BookingNetwork.swift
//  30Shine
//
//  Created by Mr.Vu on 7/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import JASON

struct BookingNetwork {
    let id : Int
    let hour : String
    let slot : Int
    let hourFrame : String
    let salonId : Int
    let currentSlot : Int
    let stylistCurrentSlot : Int
    let statusBooking : Int
    
    init(_ json : JSON) {
        id = json[.id]
        hour = json[.hour]
        slot = json[.slot]
        hourFrame = json[.hourFrame]
        salonId = json[.salonId]
        currentSlot = json[.currentSlot]
        stylistCurrentSlot = json[.stylistCurrentSlot]
        statusBooking = json[.statusBooking]
    }
}
