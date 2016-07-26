//
//  OtherServiceNetwork.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/26/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import JASON
struct  OtherServiceNetwork {
    let ID           : Int
    let name         : String
    let images       : [ImageNetWork]
    let videos       : [VideoNetwork]
    init(_ json : JSON){
        ID = json[.id]
        name = json[.name]
        images = json[.salon_images].map(ImageNetWork.init)
        videos = json[.salon_videos].map(VideoNetwork.init)
    }
}