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
    dynamic var userId : Int = 0
    dynamic var message : ContentMessage?
    
    static func create(id : Int, message : ContentMessage) -> Message! {
        let msg = Message()
        msg.userId = id
        msg.message = message
        self.createMessage(msg)
        return msg
    }
    
    static func createMessage(msg : Message) {
        try! sDB.realm.write {
                sDB.realm.add(msg)
        }
    }
    
    static func getMessageByUserId(id : Int) -> [Message] {
        var messages = [Message]()
        for msg in sDB.realm.objects(Message) {
            if msg.userId == id {
                messages.append(msg)
            }
        }
        return messages
    }
    
    static func getAllMessage() -> [Message] {
        var messages = [Message]()
        for msg in sDB.realm.objects(Message) {
            messages.append(msg)
        }
        
        return messages
    }
}

class ContentMessage : Object {
    dynamic var title : String = ""
    dynamic var time : String = ""
    dynamic var body : String = ""
    dynamic var isRead : Bool = false
    dynamic var icon : String = ""
    dynamic var image : String = ""
    
    static func create(title : String,body : String, time : String, icon : String, image: String) -> ContentMessage! {
        let ctm = ContentMessage()
        ctm.title = title
        ctm.time = time
        ctm.body = body
        ctm.isRead = false
        ctm.icon = icon
        ctm.image = image
        self.createContentMessage(ctm)
        return ctm
    }
    
    static func createContentMessage(ctm : ContentMessage) {
        try! sDB.realm.write {
            sDB.realm.add(ctm)
        }
    }
    
    static func getContentMessageByTitle(title : String) -> ContentMessage!{
        let predicate = NSPredicate(format: "title = %@", title)
        return sDB.realm.objects(ContentMessage).filter(predicate).first
    }
    
    static func hadRead(ctm : ContentMessage) {
        try! sDB.realm.write {
            ctm.isRead = true
        }
    }
    
    static func getNumberMessageNotRead() -> Int {
        var count = 0
        for msg in sDB.realm.objects(ContentMessage) {
            if !msg.isRead {
                count += 1
            }
        }
        return count
    }
}
