//
//  Message.swift
//  30Shine
//
//  Created by Apple on 8/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift

class Message: Object {
    dynamic var id : Int = 0
    dynamic var title : String = ""
    dynamic var time : String = ""
    
    static func create(id : Int, title : String, time : String) -> Message {
        let msg = Message()
        msg.id = id
        msg.time = time
        msg.title = title
        
        return msg
    }
}

extension Message {
    static func createMessage(msg : Message) {
        try! sDB.realm.write {
                sDB.realm.add(msg)
        }
    }
    
    static func getMessageByUserId(id : Int) -> Message! {
        let predicate = NSPredicate(format: "id = %d", id)
        return sDB.realm.objects(Message).filter(predicate).first
    }
}

class ContentMessage : Object {
    dynamic var title : String = ""
    dynamic var time : String = ""
    
    static func create(title : String, time : String) -> ContentMessage {
        let ctm = ContentMessage()
        ctm.title = title
        ctm.time = time
        
        return ctm
    }
    
    
}
