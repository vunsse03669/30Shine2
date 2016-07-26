//
//  HairNetwork.swift
//  30Shine
//
//  Created by Mr.Vu on 7/25/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import JASON

struct HairNetwork {
    let id    : Int
    let title : String
    let description : String
    let image : [HairImage]
    
    init(_ json : JSON) {
        description = json[.description]
        id    = json[.id]
        title = json[.title]
        image = json[.images].map(HairImage.init)
    }
}

struct HairImage {
    let url : String
    init(_ json : JSON) {
        url = json[.imageUrl]
    }
}
