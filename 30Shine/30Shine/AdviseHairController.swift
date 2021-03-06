//
//  AdviseHairController.swift
//  30Shine
//
//  Created by Apple on 8/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import ReachabilitySwift

class AdviseHairController: UIViewController {

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
        AdviseHairView.createView(self.containerView)
        
    }
    
    //MARK: Helper
    func alert(title : String, msg : String) {
        let alert = UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: "Xác nhận")
        alert.show()
    }
}
