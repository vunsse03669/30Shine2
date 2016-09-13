//
//  AdviseSkinController.swift
//  30Shine
//
//  Created by Đỗ Ngọc Trình on 8/23/16.
//  Copyright © 2016 vu. All rights reserved.
//


import UIKit
import ReachabilitySwift

class AdviseSkinController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    var reachability : Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    //MARK: Config UI
    func handleBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func handleProfile() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SelectProfileController") as! SelectProfileController
        self.navigationController?.push(vc, animated: true)
    }
    
    
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationController?.navigationBar.translucent = false
        //back image
        var backImage = UIImage(named: "img-back")
        backImage = backImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleBackButton))
        self.addRightButton(self.handleProfile)
        
        //create advise hair view
        AdviseSkinView.createView(self.containerView)
        
    }
    
    //MARK: check internet
    func checkInternet() {
        do {
            reachability = try! Reachability.reachabilityForInternetConnection()
        }
        reachability!.whenReachable = {
            reachability in
            dispatch_async(dispatch_get_main_queue()) {
            
            }
        }
        reachability!.whenUnreachable = {
            reachability in
            dispatch_async(dispatch_get_main_queue()) {
                
            }
        }
        try! reachability?.startNotifier()
    }
    
    //MARK: Helper
    func alert(title : String, msg : String) {
        let alert = UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: "Xác nhận")
        alert.show()
    }
}
