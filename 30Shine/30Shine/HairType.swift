//
//  HairType.swift
//  30Shine
//
//  Created by Mr.Vu on 7/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import RealmSwift

class HairType: Object {
    dynamic var title     : String = ""
    dynamic var script    : String = ""
    dynamic var id        : Int    = 0
    var images : List<Imagee> = List<Imagee>()
    
    static func create(id: Int, title : String, script : String, imageName : List<Imagee>) -> HairType! {
        let hairType = HairType()
        hairType.id = id
        hairType.title = title
        hairType.script = script
        hairType.images = imageName
        self.createHairType(hairType)
        return hairType
    }
}

class Imagee : Object {
    dynamic var imageUrl : String = ""
    static func create(imageUrl : String) -> Imagee {
        let image = Imagee()
        image.imageUrl = imageUrl
        self.createImagee(image)
        return image
    }
}

extension HairType {
    static func createHairType(hairType : HairType) {
        try! sDB.realm.write {
            sDB.realm.add(hairType)
        }
    }
    
    static func getHairTypeById(id : Int) -> HairType! {
        let predicate = NSPredicate(format: "id = %d", id)
        return sDB.realm.objects(HairType).filter(predicate).first
    }
}

extension Imagee {
    static func createImagee(image : Imagee) {
        try! sDB.realm.write {
            sDB.realm.add(image)
        }
    }
    
    static func getImageeByUrl(url : String) -> Imagee! {
        let predicate = NSPredicate(format: "imageUrl = %@", url)
        return sDB.realm.objects(Imagee).filter(predicate).first
    }
}
