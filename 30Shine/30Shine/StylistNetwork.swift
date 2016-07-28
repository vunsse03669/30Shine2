//
//  StylistNetwork.swift
//  30Shine
//
//  Created by Mr.Vu on 7/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import JASON

struct StylistNetwork{
    let id: Int
    let fullName: String
    let salonId: Int
    
    init(_ json : JSON) {
        id = json[.id]
        fullName = json[.fullName]
        salonId = json[.salonId]
    }
}

