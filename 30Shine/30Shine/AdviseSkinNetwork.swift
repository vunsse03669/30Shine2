//
//  AdviseHairNetwork.swift
//  30Shine
//
//  Created by Apple on 8/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import JASON

struct AdviseSkinNetwork {
    let skinAttribute : String
    let description : String
    let dateConsultant : String
    let products : [ProductNetwork]
    
    init(_ json : JSON) {
        skinAttribute = json[.advise_skinAttribute]
        description = json[.advise_description]
        dateConsultant = json[.advise_dateConsultant]
        products = json[.advise_product].map(ProductNetwork.init)
    }
}

