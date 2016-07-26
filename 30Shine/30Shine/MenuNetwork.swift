//
//  MenuNetwork.swift
//  30Shine
//
//  Created by Mr.Vu on 7/23/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import Foundation
import JASON

struct MenuNetwork {
    let name : String
    let thumb : Thumb
    
    init(_ json : JSON) {
        name = json[.name]
        thumb = Thumb.init(json[.thumb])
    }
}

struct Thumb {
    let imageUrl : String
    init(_ json : JSON) {
        imageUrl = json[.imageUrl]
    }
}
