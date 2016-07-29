//
//  OtherServiceNetwork.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/26/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation
import Alamofire
import JASON
struct  OtherServiceNetwork {
    let ID           : Int
    let name         : String
    let images       : [ImageNetWork]
    let videos       : [VideoNetwork]
    init(_ json : JSON){
        ID = json[.id]
        name = json[.name]
        images = json[.salon_images].map(ImageNetWork.init)
        videos = json[.salon_videos].map(VideoNetwork.init)
    }
}

let sNetworkSender = NetworkSender.sharedInstance
class NetworkSender{
    
    static let sharedInstance = NetworkSender()
    
    func sendBooking(customerName: String, phone: String, salonID: String, dateBook: String, StylistId : String, hourId : String){
        
        let parameters = [
            "CustomerName" : customerName,
            "CustomerPhone" : phone,
            "SalonId" : salonID,
            "DateBook" : dateBook,
            "StylistId" : StylistId,
            "HourId" : hourId
        ]
        
        Alamofire.request(.POST, BOOKING_API, parameters: parameters, encoding: .JSON)
            .responseJSON{
                response in
                switch response.result {
                case .Failure(let error):
                    print(error)
                case .Success(let responseObject):
                    print(responseObject)
                    print("Booking DONE!")
                }
        }
        
    }
}

extension UINavigationController{
    func push(viewController : UIViewController, animated : Bool){
        //        let animation = CATransition()
        //        animation.duration = 0.45
        //        animation.type = kCATransitionPush
        //        animation.subtype = kCATransitionFromRight
        //        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        //        viewController.view.layer.addAnimation(animation, forKey: "")
        self.pushViewController(viewController, animated: true)
    }
    
    func pop(){
        
        let viewControllers: [UIViewController] = self.viewControllers as [UIViewController];
        for vc in viewControllers {
            self.popToViewController(vc, animated: true)
        }
    }
}