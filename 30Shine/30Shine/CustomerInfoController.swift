//
//  CustomerInfoController.swift
//  30Shine
//
//  Created by Apple on 8/11/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class CustomerInfoController: UIViewController, UIAlertViewDelegate {
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnModification: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtYob: UITextField!
    @IBOutlet weak var txtMob: UITextField!
    @IBOutlet weak var txtDob: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtName: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.logout()
        self.modificationInfo()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.bindingData()
    }
    
    func handleBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
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
        
        //Texfield
        self.txtYob.layoutIfNeeded()
        self.txtDob.layoutIfNeeded()
        self.txtMob.layoutIfNeeded()
        
        self.configTextField(self.txtName, padding: 5, type: UIKeyboardType.Default)
        self.configTextField(self.txtPhone, padding: 5, type: UIKeyboardType.NumberPad)
        self.configTextField(self.txtDob, padding: self.txtDob.frame.width/2 - 8, type: UIKeyboardType.NumberPad)
        self.configTextField(self.txtMob, padding: self.txtMob.frame.width/2 - 8, type: UIKeyboardType.NumberPad)
        self.configTextField(self.txtYob, padding: self.txtYob.frame.width/2 - 16, type: UIKeyboardType.NumberPad)
        self.configTextField(self.txtEmail, padding: 5, type: UIKeyboardType.Default)
    }
    
    func configTextField(textField : UITextField, padding : CGFloat, type : UIKeyboardType) {
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(padding, 0, 0)
        textField.keyboardType = type
        textField.userInteractionEnabled = false
    }
    
    //MARK: Data
    func bindingData() {
        let name  = Login.getLogin().fullName
        let phone = Login.getLogin().phone
        let dob   = Login.getLogin().dayOfbirth
        let mob   = Login.getLogin().monthOfBirth
        let yob   = Login.getLogin().yearOfBirth
        let email = Login.getLogin().email
        
        self.txtName.text  = name
        self.txtPhone.text = phone
        self.txtEmail.text = email
        self.txtDob.text   = self.convertNumberToString(dob)
        self.txtMob.text   = self.convertNumberToString(mob)
        self.txtYob.text   = self.convertNumberToString(yob)
    }
    
    func convertNumberToString(num : Int) -> String {
        var str = ""
        if num < 10 {
            str = "0\(num)"
        }
        else {
            str = "\(num)"
        }
        return str
    }
    
    //MARK: Logout
    func logout() {
        _ = btnLogout.rx_tap.subscribeNext {
            let alert = UIAlertView(title: "", message: "Bạn thực sự muốn đăng xuất?", delegate: self, cancelButtonTitle: "Không", otherButtonTitles: "Có")
            alert.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            Login.deleteLogin()
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginController") as! LoginController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: Modification Customer info
    func modificationInfo() {
        _ = self.btnModification.rx_tap.subscribeNext {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ModificationCustomerInfoController") as! ModificationCustomerInfoController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
