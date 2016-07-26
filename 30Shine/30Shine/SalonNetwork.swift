//
//  SalonNetwork.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/25/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import JASON

struct  SalonNetwork {
    let ID           : Int
    let name         : String
    let phone        : String
    let managerName  : String
    let fanpage      : String
    let images       : [ImageNetWork]
    
    init(_ json : JSON){
        ID = json[.id]
        name = json[.name]
        phone = json[.salon_phone]
        managerName = json[.salon_managerName]
        fanpage = json[.salon_fanpage]
        images = json[.salon_images].map(ImageNetWork.init)
    }
}

struct ImageNetWork {
    var url         : String = ""
    var thumb       : String = ""
    var title       : String = ""
    var img_description : String = ""
    
    init(_ json : JSON){
        url = json[.imageUrl]
        thumb = json[.salon_imageThumb]
        title = json[.salon_title]
        img_description = json[.salon_description]
    }
}