//
//  BookingNotification.swift
//  30Shine
//
//  Created by Mr.Vu on 7/31/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift

class BookingNotification: Object {
    dynamic var id = 1
    dynamic var showMessage = 1
    
    static func create(id : Int, showMessage : Int) -> BookingNotification! {
        let notification = BookingNotification()
        notification.showMessage = showMessage
        notification.id = id
        self.createNotification(notification)
        return notification
    }
}

extension BookingNotification {
    static func createNotification(notification : BookingNotification) {
        try! sDB.realm.write {
            sDB.realm.add(notification)
        }
    }
    
    static func getNotificationById(id : Int) -> BookingNotification! {
        let predicate = NSPredicate(format: "id = %d", id)
        return sDB.realm.objects(BookingNotification).filter(predicate).first
    }
    
    static func updateMessage(notification: BookingNotification, message : Int) {
        try! sDB.realm.write {
            notification.showMessage = message
        }
    }
}
