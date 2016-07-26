//
//  HistoryNetwork.swift
//  30Shine
//
//  Created by Mr.Vu on 7/23/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import JASON

struct HistoryNetwork {
    let billCreatedTime : String
    let stylistName : String
    let skinnerName : String
    let rating : String
    let services : [Services]
    
    init(_ json : JSON) {
        billCreatedTime = json[.billCreatedTime]
        stylistName = json[.stylistName]
        skinnerName = json[.skinnerName]
        rating = json[.rating]
        services = json[.services].map(Services.init)
    }
}

struct Services {
    let name : String
    init(_ json : JSON) {
        name = json[.name]
    }
}