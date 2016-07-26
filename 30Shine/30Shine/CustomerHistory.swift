//
//  CustomerHistory.swift
//  30Shine
//
//  Created by Mr.Vu on 7/23/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift

class CustomerHistory: Object {
    dynamic var createTime: String = ""
    dynamic var stylistName : String = ""
    dynamic var skinnerName : String = ""
    dynamic var rating : String = ""
    dynamic var service : String = ""
    
    static func create(time : String, stylist : String, skinner : String, rating : String, service : String) -> CustomerHistory {
        let history = CustomerHistory()
        history.createTime = time
        history.stylistName = stylist
        history.skinnerName = skinner
        history.rating = rating
        history.service = service
        self.createCustomerHistory(history)
        return history
    }
}

extension CustomerHistory {
    static func createCustomerHistory(history : CustomerHistory) {
        try! sDB.realm.write {
            sDB.realm.add(history)
        }
    }
    
    static func getCustomerHistoryByTime(time : String) -> CustomerHistory! {
        let predicate = NSPredicate(format: "createTime = %@", time)
        return sDB.realm.objects(CustomerHistory).filter(predicate).first
    }
}