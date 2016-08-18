//
//  YoutubeNetwork.swift
//  30Shine
//
//  Created by Mr.Vu on 7/27/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import JASON

struct YoutubeNetwork {
    let id : Int
    let link : String
    let title : String
    let viewCount : Int
    let thumb : String
    let publishDate : String
    let videoId : String
    
    init(_ json : JSON) {
        id = json[.youtube_id]
        link = json[.youtube_link]
        title = json[.youtube_title]
        viewCount = json[.youtube_viewCount]
        thumb = json[.youtube_thumb]
        publishDate = json[.youtube_publishDate]
        videoId = json[.youtube_videoId]
    }
}

