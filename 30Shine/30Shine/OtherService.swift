//
//  OtherServices.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/26/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import RealmSwift
class OtherService: Object {
    dynamic var ID           : Int = -1
    dynamic var name         : String = ""
    var listImages : List<ImageObject> = List<ImageObject>()
    var listVideos : List<VideoObject> = List<VideoObject>()
    
    static func create(id : Int, name: String, listImages: List<ImageObject>, listVideos: List<VideoObject>)-> OtherService{
        let otherService = OtherService()
        otherService.ID = id
        otherService.name = name
        otherService.listImages = listImages
        otherService.listVideos = listVideos
        return otherService
    }
}

extension OtherService {
    static func createSalon(combo : OtherService){
        try! sDB.realm.write({
            sDB.realm.add(combo)
        })
    }
    
    static func getSalonByID( id : Int)->OtherService! {
        let predicate = NSPredicate(format: "ID = %d",id)
        return sDB.realm.objects(OtherService).filter(predicate).first
    }
    
    static func getAllSalon()-> Results<OtherService>{
        return sDB.realm.objects(OtherService)
    }
}

