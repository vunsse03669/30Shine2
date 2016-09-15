//
//  Message.swift
//  30Shine
//
//  Created by Apple on 8/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift

class Message: Object {
    dynamic var userId : Int = 0
    dynamic var message : ContentMessage?
    static var messageReceived = false
    static var messageReceiveComplettion : (() -> Void)!
    static var openMessageRequest : (() -> Void)!
    
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
        // Sort the messages so that the latest will appear first
        // Since the stupid time format ís hh:mm yyy:mm:dd, it must be splitted to be able to compare
        return messages.sort {
            message1, message2 in
            // Split the two arrays
            let timeArray1 = message1.message?.time.componentsSeparatedByString(" ")
            let timeArray2 = message2.message?.time.componentsSeparatedByString(" ")
            print("\(message1.message?.time) vs \(message2.message?.time)")
            if timeArray1 == nil || timeArray1?.count < 2 {
                return false
            }
            else if timeArray2 == nil || timeArray2?.count < 2 {
                return true
            }
            else {
                if let date1 = timeArray1![1].toDate() {
                    if let date2 = timeArray2![1].toDate() {
                        if date1.compare(date2) == .OrderedDescending {
                            return true
                        }
                        else if date1.compare(date2) == .OrderedAscending {
                            return false
                        } else {
                            return timeArray1![0] > timeArray2![0]
                        }
                    }
                }
                print("Could not convert datetime : \(timeArray1![1])  - \(timeArray2![1])")
                return true
            }
        }
    }
    
    static func getAllMessage() -> [Message] {
        var messages = [Message]()
        for msg in sDB.realm.objects(Message) {
            messages.append(msg)
        }
        
        return messages
    }
    
    override class func ignoredProperties() -> [String] { return ["messageReceived", "messageReceiveComplettion"] }
}

class ContentMessage : Object {
    dynamic var messageId : String = ""
    dynamic var title : String = ""
    dynamic var time : String = ""
    dynamic var body : String = ""
    dynamic var isRead : Bool = false
    dynamic var icon : String = ""
    dynamic var image : String = ""
    
    static var messageCountVar : Variable<Int> = Variable(0)
    
    static func create(messageId: String, title : String,body : String, time : String, icon : String, image: String) -> ContentMessage! {
        let ctm = ContentMessage()
        ctm.messageId = messageId
        ctm.title = title
        ctm.time = time
        ctm.body = body
        ctm.isRead = false
        ctm.icon = icon
        ctm.image = image
//        self.createContentMessage(ctm)
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
        updateNumberMessageNotRead()
    }
    
    static func updateNumberMessageNotRead() {
        var count = 0
        for msg in sDB.realm.objects(ContentMessage) {
            if !msg.isRead {
                count += 1
            }
        }
        messageCountVar.value = count
    }
    
    static func exists(messageId: String) -> Bool {
        return sDB.realm.objects(ContentMessage).filter("messageId == '\(messageId)'").count > 0
    }
    
//    static func getNumberMessageNotRead() -> Int {
//        var count = 0
//        for msg in sDB.realm.objects(ContentMessage) {
//            if !msg.isRead {
//                count += 1
//            }
//        }
//        return count
//    }
    
    override class func ignoredProperties() -> [String] { return ["messageCountVar"] }
}
