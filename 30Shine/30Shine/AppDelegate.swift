//
//  AppDelegate.swift
//  30Shine
//
//  Created by Mr.Vu on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import MediaPlayer
import TTGSnackbar
import ReachabilitySwift
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import AVFoundation



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate {
    
    var window: UIWindow?
    var reachability : Reachability?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        if #available(iOS 8.0, *) {
            // [START register_for_notifications]
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            // [END register_for_notifications]
        } else {
            // Fallback
            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            application.registerForRemoteNotificationTypes(types)
        }
        
        FIRApp.configure()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.tokenRefreshNotification),
                                                         name: kFIRInstanceIDTokenRefreshNotification,
                                                         object: nil)
        
        self.window!.backgroundColor = .whiteColor();
        self.checkInternet()
        self.checkLogin()
        
        // Raise messageRecevied flag when app is launched by Notification
        if launchOptions != nil && launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey] != nil {
            //Message.messageReceived = true
        }
        
        ContentMessage.updateNumberMessageNotRead()

        return true
    }
    
    
    
    // NOTE: Need to use this when swizzling is disabled
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Unknown)
        print("Device Token:", tokenString)
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        // NOTE: It can be nil here
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            if NotificationToken.getToken() == nil {
                NotificationToken.create(refreshedToken)
            }
            else {
                let notificationToken = NotificationToken.getToken()
                NotificationToken.updateToken(notificationToken, newToken: refreshedToken)
            }
            FIRMessaging.messaging().subscribeToTopic("/topics/all-users")
            print("Subscribe to topics")
            SendTokenNotification.shareInstance.sendTokenNotification({
            })
        }
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("[ERROR remote] \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        
        
        // Print message ID.
        //let state = UIApplication.sharedApplication().applicationState
        //if state == .Background {
            
        //} else if state == .Inactive {
            

        //} else if state == .Active {
            print("Message ID: \(userInfo["gcm.message_id"]!)")
            print(".........: \(userInfo["aps"]!["alert"]!!["title"])")
            var userId = 0
            var title = ""
            var body = ""
            var time = ""
            var icon = ""
            var image = ""
            var messageId = String(userInfo["gcm.message_id"]!)
        
            if ContentMessage.exists(messageId) {
                completionHandler(.NoData)
                return
            }
        
            if Login.getLogin() != nil {
                userId = Login.getLogin().id
            }
            
            print("xxxxxxxxxxxxxxxxx: \(userInfo)")
            if let tit = userInfo["aps"]!["alert"]!!["title"]! {
                title = String(tit)
            }
            //        if let bod = userInfo["aps"]!["alert"]!!["body"]! {
            //            body = String(bod)
            //        }
            if let bod = userInfo["text"] {
                body = String(bod)
            }
            if let ti = userInfo["send_time"] {
                time = String(ti)
            }
            if let ic = userInfo["icon"] {
                icon = String(ic)
            }
            if let im = userInfo["image"] {
                image = String(im)
            }
            print("time : \(time)")
            let ctm = ContentMessage.create(messageId, title: title, body: body, time: time, icon: icon, image: image)
            
            Message.create(userId, message: ctm)
            
            ContentMessage.updateNumberMessageNotRead()
        
            if Message.messageReceiveComplettion != nil{
                Message.messageReceiveComplettion()
            }
        
            let state = UIApplication.sharedApplication().applicationState
            if state == .Background {
                print("Background")
            } else if state == .Inactive {
                print("Inactive")
                Message.messageReceived = true
                if Message.openMessageRequest != nil {
                    Message.openMessageRequest()
                }
            } else if state == .Active {
                print("Active")
            }
        
            completionHandler(.NewData)
        //}
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
    }
    
//    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        
//       // application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1;
//        
//        let dateformatter = NSDateFormatter()
//        
//        dateformatter.dateFormat = "HH:mm dd/MM/yyyy"
//        
//        let now = dateformatter.stringFromDate(NSDate()).stringByReplacingOccurrencesOfString(":", withString: "h")
//        
//        var userId = 0
//        var title = ""
//        if #available(iOS 8.2, *) {
//            title = notification.alertTitle!
//        } else {
//            // Fallback on earlier versions
//        }
//        let body = notification.alertBody!
//        let time = now
//        let icon = "img-calendar"
//        
//        
//        if Login.getLogin() != nil {
//            userId = Login.getLogin().id
//        }
//        
//        
//        let ctm = ContentMessage.create(title, body: body, time: time, icon: icon, image:  "")
//        
//        Message.create(userId, message: ctm)
//        print("\(Message.getAllMessage())")
//        
//        let alert = UIAlertView(title: title, message: body, delegate: nil, cancelButtonTitle: "OK")
//        self.window?.rootViewController?.view.addSubview(alert)
//        alert.show()
//        
////        let snackbar = TTGSnackbar.init(message: "You have a new message", duration: .Middle, actionText: "Xem tinh nhắn")
////        { (snackbar) -> Void in
////            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
////            let loginPageView = mainStoryboard.instantiateViewControllerWithIdentifier("MessageController") as! MessageController
////            let rootViewController = self.window!.rootViewController as! UINavigationController
////            rootViewController.pushViewController(loginPageView, animated: true)
////        }
//        //self.window?.rootViewController?.view .addSubview(snackbar)
//    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //FIRMessaging.messaging().disconnect()
        //print("Disconnected from FCM.")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connectToFcm()
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        
        let vc = self.window?.rootViewController?.presentedViewController
        
        if((vc?.isKindOfClass(MPMoviePlayerViewController)) != nil){
            return .AllButUpsideDown;
        }
        
        if(((vc?.isKindOfClass(UINavigationController))) != nil){
            let nc = vc as! UINavigationController
            
            if((nc.topViewController?.isKindOfClass(MPMoviePlayerViewController)) != nil){
                return .AllButUpsideDown
            }
            else if((nc.topViewController?.presentedViewController?.isKindOfClass(MPMoviePlayerViewController)) != nil){
                return .AllButUpsideDown
            }
            
        }
        return .Portrait;
    }
    
    //MARK: Internet
    func checkLogin() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if Login.getLogin() != nil {
            let nvc = mainStoryBoard.instantiateViewControllerWithIdentifier("HomeNavigation") as! HomeNavigation
            self.window?.rootViewController = nvc
            
        }
        else {
            let nvc = mainStoryBoard.instantiateViewControllerWithIdentifier("loginNavigation") as! loginNavigation
            self.window?.rootViewController = nvc
            
        }
        self.window?.makeKeyAndVisible()
        
    }
    
    func checkInternet() {
        do {
            reachability = try! Reachability.reachabilityForInternetConnection()
        }
        reachability!.whenUnreachable = {
            reachability in
            dispatch_async(dispatch_get_main_queue()) {
                let message = "Mất kết nối internet. Chương trình sẽ tiếp tục chạy offline."
                let alert = UIAlertView(title: "", message: message, delegate: nil, cancelButtonTitle: "Xác nhận")
                alert.show()
            }
        }
        reachability!.whenReachable = {
            reachability in
            dispatch_async(dispatch_get_main_queue()){
                
            }
        }
        
        try! reachability?.startNotifier()
        
    }
}




