//
//  NotificationToken.swift
//  30Shine
//
//  Created by Apple on 8/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift

class NotificationToken: Object {
    dynamic var currentToken : String! = ""
    dynamic var oldToken : String! = ""
    
    static func create(currentToken : String) -> NotificationToken {
        let noteToken = NotificationToken()
        noteToken.currentToken = currentToken
        noteToken.oldToken = ""
        self.createNotificationToken(noteToken)
        return noteToken
    }
}

extension NotificationToken {
    static func createNotificationToken(token : NotificationToken) {
        try! sDB.realm.write {
            sDB.realm.add(token)
        }
    }
    
    static func getToken() -> NotificationToken! {
        return sDB.realm.objects(NotificationToken).first
    }
    
    static func updateToken(notificationToken : NotificationToken, newToken : String) {
        try! sDB.realm.write {
            notificationToken.oldToken = notificationToken.currentToken
            notificationToken.currentToken = newToken
        }
    }
}
