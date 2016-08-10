//
//  StylistWorkTime.swift
//  30Shine
//
//  Created by Apple on 8/11/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import JASON

struct StylistWorkTime {
    let staffId : Int
    let hourIds : String
    
    init(_ json : JSON) {
        hourIds = json[.hourIds]
        staffId = json[.staffId]
    }
}
