//
//  AdviseHairNetwork.swift
//  30Shine
//
//  Created by Apple on 8/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import JASON

struct AdviseHairNetwork {
    let description : String
    let dateConsultant : String
    let products : [ProductNetwork]
    
    init(_ json : JSON) {
        description = json[.advise_description]
        dateConsultant = json[.advise_dateConsultant]
        products = json[.advise_product].map(ProductNetwork.init)
    }
}

struct ProductNetwork {
    let id          : Int
    let productName : String
    let price       : Int
    let thumb       : String
    
    init(_ json : JSON) {
        id          = json[.advise_id]
        productName = json[.advise_productName]
        price       = json[.advise_price]
        thumb       = json[.advise_thumb]
    }
}
