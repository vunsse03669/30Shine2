//
//  YoutubeVideo.swift
//  30Shine
//
//  Created by Mr.Vu on 7/27/16.
//  Copyright © 2016 vu. All rights reserved.
//

import RealmSwift

class YoutubeVideo: Object {
    
    dynamic var id : Int = 0
    dynamic var title : String = ""
    dynamic var link : String = ""
    dynamic var thumb : String = ""
    dynamic var viewCount : Int = 0
    dynamic var publishDate: String = ""
    dynamic var videoId : String = ""
    
    static func create(id : Int, title : String,link : String,thumb: String, viewCount : Int, publistDate : String, videoId : String) -> YoutubeVideo! {
        let video = YoutubeVideo()
        video.id = id
        video.title = title
        video.link = link
        video.thumb = thumb
        video.viewCount = viewCount
        video.publishDate = publistDate
        video.videoId = videoId
        print("\(video.title)")
        self.createVideo(video)
        return video
    }

}

extension YoutubeVideo {
    static func createVideo(video : YoutubeVideo) {
        try! sDB.realm.write {
            sDB.realm.add(video)
        }
    }
    
    static func getVideoById(id : Int) -> YoutubeVideo! {
        let predicate = NSPredicate(format: "id = %d", id)
        return sDB.realm.objects(YoutubeVideo).filter(predicate).first
    }
}
