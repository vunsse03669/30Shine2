//
//  SendTokenNotification.swift
//  30Shine
//
//  Created by Apple on 8/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import Alamofire

class SendTokenNotification: NSObject {
    static let shareInstance = SendTokenNotification()
    private override init() {}
    
    func sendTokenNotification(completion:()->()) {
        var userID : Int!
        var oldToken : String!
        var currentToken : String!
        
        if Login.getLogin() != nil {
            userID = Login.getLogin().id
        }
        else {
            userID = 0
        }
        
        if NotificationToken.getToken() != nil {
            oldToken = NotificationToken.getToken().oldToken
            currentToken = NotificationToken.getToken().currentToken
        }
        else {
            return
        }
        
        let parameters = ["UserId" : userID, "OldToken" : oldToken, "CurrentToken" : currentToken]
        let kUpdateNotificationToken = "http://api.30shine.com/device/update"
        
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            Alamofire.request(.POST, kUpdateNotificationToken, parameters: parameters as? [String : AnyObject], encoding: .JSON).responseJASON {
                response in
                if let json = response.result.value {
                    print(json)
                }
            }
        }
    }
    
    func sendTokenNotificationLogout(completion:()->()) {
        
        var oldToken : String!
        var currentToken : String!
        

        if NotificationToken.getToken() != nil {
            oldToken = NotificationToken.getToken().oldToken
            currentToken = NotificationToken.getToken().currentToken
        }
        else {
            return
        }
        
        let parameters = ["UserId" : 0, "OldToken" : oldToken, "CurrentToken" : currentToken]
        let kUpdateNotificationToken = "http://api.30shine.com/device/update"
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            Alamofire.request(.POST, kUpdateNotificationToken, parameters: parameters as? [String : AnyObject], encoding: .JSON).responseJASON {
                response in
                if let json = response.result.value {
                    print(json)
                }
            }
        }
    }
}
