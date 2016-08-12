//
//  ModificationCustomerInfoController.swift
//  30Shine
//
//  Created by Apple on 8/12/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ModificationCustomerInfoController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var txtYob: UITextField!
    @IBOutlet weak var txtMob: UITextField!
    @IBOutlet weak var txtDob: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    func handleBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func handleProfileButton() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SelectProfileController") as! SelectProfileController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: UI
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
        //profile image
        var profileImage = UIImage(named: "img-people")
        profileImage = profileImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: profileImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleProfileButton))
    }
}
