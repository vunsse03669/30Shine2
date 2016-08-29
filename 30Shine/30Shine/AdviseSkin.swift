//
//  AdviseSkin.swift
//  30Shine
//
//  Created by Apple on 8/29/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift

class AdviseSkin: Object {
    dynamic var hairAttribute : String = ""
    dynamic var descriptionn : String = ""
    dynamic var dateConsultant : String = ""
    var product : List<Product> = List<Product>()
    
    static func create(description : String, date : String, product : List<Product>, skinAttribute : String) -> AdviseSkin {
        let adviseSkin = AdviseSkin()
        adviseSkin.hairAttribute = skinAttribute
        adviseSkin.descriptionn = description
        adviseSkin.dateConsultant = date
        adviseSkin.product = product
        self.createadviseSkin(adviseSkin)
        return adviseSkin
    }
}

extension AdviseSkin {
    static func createadviseSkin(adviseSkin : AdviseSkin) {
        try! sDB.realm.write {
            sDB.realm.add(adviseSkin)
        }
    }
    
    static func getadviseSkinByDate(date : String) -> AdviseSkin! {
        let predicate = NSPredicate(format: "dateConsultant = %@", date)
        return sDB.realm.objects(AdviseSkin).filter(predicate).first
    }
    
    static func getAdviseSkin() -> AdviseSkin! {
        return sDB.realm.objects(AdviseSkin).first
    }
}
