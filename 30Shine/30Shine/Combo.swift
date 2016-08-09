//
//  Combo.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift

class Combo: Object {
    dynamic var ID           : Int = -1
    dynamic var name         : String = ""
    dynamic var textTitle   : String = ""
    var listComboSteps : List<ComboStep> = List<ComboStep>()
    var listVideos:List<VideoObject> = List<VideoObject>()
    static func create(id : Int, name: String, listSteps: List<ComboStep>, listVideos:List<VideoObject>)-> Combo{
        let combo = Combo()
        combo.ID = id
        combo.name = name
        combo.listComboSteps = listSteps
        combo.listVideos = listVideos
        return combo
    }
}

extension Combo {
    static func createSalon(combo : Combo){
        try! sDB.realm.write({
            sDB.realm.add(combo)
        })
    }
    
    static func getSalonByID( id : Int)->Combo! {
        let predicate = NSPredicate(format: "ID = %d",id)
        return sDB.realm.objects(Combo).filter(predicate).first
    }
    
    static func getAllSalon()-> Results<Combo>{
        return sDB.realm.objects(Combo)
    }
}

class ComboStep: Object {
    
    dynamic var url         : String = ""
    dynamic var thumb       : String = ""
    dynamic var title       : String = ""
    dynamic var img_description : String = ""
    
    static func create(url : String, thumb: String, title : String, img_description : String) -> ComboStep{
        let comboStep = ComboStep()
        comboStep.url = url.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        comboStep.thumb = thumb.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        comboStep.title = title
        comboStep.img_description = img_description
        self.create(comboStep)
        return comboStep
    }
    
    static func create(comboStep : ComboStep) {
        try! sDB.realm.write {
            sDB.realm.add(comboStep)
        }
    }
    
    static func getAllComboStep() -> [ComboStep] {
        var comboSteps = [ComboStep]()
        for comboStep in sDB.realm.objects(ComboStep) {
            comboSteps.append(comboStep)
        }
        return comboSteps
    }
}

class VideoObject: Object{
    dynamic var url         : String = ""
    dynamic var thumb       : String = ""
    dynamic var title       : String = ""
    dynamic var img_description : String = ""
    
    static func create(url : String, thumb: String, title : String, img_description : String) -> VideoObject{
        let videoObj = VideoObject()
        videoObj.url = url.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        
        videoObj.thumb = thumb.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        videoObj.title = title
        videoObj.img_description = img_description
        return videoObj
    }
    
}

