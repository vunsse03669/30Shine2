//
//  ComboNetwork.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/26/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import JASON

struct  ComboNetwork {
    let ID           : Int
    let name         : String
    let combosteps       : [ComboStepNetWork]
    let  videos       : [VideoNetwork]
    
    init(_ json : JSON){
        ID = json[.id]
        name = json[.name]
        combosteps = json[.salon_images].map(ComboStepNetWork.init)
        videos = json[.salon_videos].map(VideoNetwork.init)
    }
}

struct ComboStepNetWork {
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

struct  VideoNetwork {
    
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

