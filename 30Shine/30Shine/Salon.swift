//
//  Salon.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift

class Salon: Object {
    
    dynamic var ID           : Int = -1
    dynamic var name         : String = ""
    dynamic var phone        : String = ""
    dynamic var managerName  : String = ""
    dynamic var fanpage      : String = ""
    var listImages           : List<ImageObject> = List<ImageObject>()
    
    static func create(id:Int, name:String, phone: String, managerName: String, fanpage:String, listImages : List<ImageObject>) -> Salon{
        let salon = Salon()
        salon.ID = id
        salon.name = name
        salon.phone = phone
        salon.managerName = managerName
        salon.fanpage = fanpage
        salon.listImages = listImages
        self.createSalon(salon)
        return salon
    }
}
extension Salon {
    static func createSalon(salon : Salon){
        try! sDB.realm.write({
            sDB.realm.add(salon)
        })
    }
    
    static func getSalonByID( id : Int)->Salon! {
    let predicate = NSPredicate(format: "ID = %d",id)
        return sDB.realm.objects(Salon).filter(predicate).first
    }
    
    static func getAllSalon()-> [Salon]{
        var salons = [Salon]()
        for salon in sDB.realm.objects(Salon) {
            salons.append(salon)
        }
        return salons
    }
}
class ImageObject : Object{
    dynamic var url         : String = ""
    dynamic var thumb       : String = ""
    dynamic var title       : String = ""
    dynamic var img_description : String = ""
    
    static func create(url : String, thumb: String, title : String, img_description : String) -> ImageObject{
        let salonImage = ImageObject()
        salonImage.url = url.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        
        salonImage.thumb = thumb.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        salonImage.title = title
        salonImage.img_description = img_description
        return salonImage
    }
}
