//
//  AppDelegate.swift
//  30Shine
//
//  Created by Mr.Vu on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import MediaPlayer
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var reachability : Reachability?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()

        self.window!.backgroundColor = .whiteColor();
        self.checkInternet()
        return true
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

    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
}




