//
//  SlideNetwork.swift
//  30Shine
//
//  Created by Mr.Vu on 7/23/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import JASON

struct SlideNetwork {
    let image : Image
    init(_ json : JSON) {
        image = Image.init(json[.image])
    }
}

struct Image {
    let imageUrl : String
    init(_ json : JSON) {
        imageUrl = json[.imageUrl]
    }
}
