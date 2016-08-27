//
//  ForgetPasswordController.swift
//  30Shine
//
//  Created by Apple on 8/27/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import SVProgressHUD

class ForgetPasswordController: UIViewController {
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    
    var updateSuccess = false
    let successMessage = "Mật khẩu của bạn đã được gửi vào email đăng ký. Vui lòng kiểm tra email để nhận lại mật khẩu!"
    let failMessage = "Quá trình lấy lại mật khẩu gặp sự cố. Quý khách vui lòng kiểm tra lại thông tin"
    
    let invalidMessage = "Quá trình lấy lại mật khẩu gặp sự cố. Quý khách vui lòng kiểm tra lại thông tin"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.tappedBtnSubmit()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        txtPhone.text = "01663234748"
        txtMail.text = "mrnguyensonvuads@gmail.com"
    }
    
    
    //MARK: hide keyboard
    func keyboardWillShow(notification: NSNotification) {
        self.hideKeyboardWhenTappedAround()
    }
    
    func keyboardWillHide(notification: NSNotification) {
        for recognizer in view.gestureRecognizers ?? [] {
            view.removeGestureRecognizer(recognizer)
        }
    }
    
    func handleBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: UI
    func configUI() {
        //logo
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationController?.navigationBar.translucent = false
        
        self.txtPhone.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        self.txtPhone.keyboardType = .DecimalPad
        self.txtMail.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        //back image
        var backImage = UIImage(named: "img-back")
        backImage = backImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleBackButton))
    }

    //MARK: Send data to server
    
    func tappedBtnSubmit() {
        _ = self.btnSubmit.rx_tap.subscribeNext {
            //check...
            guard let phone = self.txtPhone.text, email = self.txtMail.text else {
                return
            }
            
            if !self.validate(phone, email: email) {
                let forgetView = ForgetAlertView.createView(self.view, msg: self.invalidMessage)
                forgetView.delegate = self
                self.view.backgroundColor = UIColor(netHex: 0x9E9E9E)
                return
            }
            
            self.setUserInteraction(false)
            SVProgressHUD.showWithStatus("Đang tải dữ liệu")
            self.requestToServer(phone, mail: email, completion: { 
                self.setUserInteraction(true)
                SVProgressHUD.popActivity()
                if self.updateSuccess {
                    let forgetView = ForgetAlertView.createView(self.view, msg: self.successMessage)
                    forgetView.delegate = self
                    self.view.backgroundColor = UIColor(netHex: 0x9E9E9E)
                }
                else{
                    let forgetView = ForgetAlertView.createView(self.view, msg: self.failMessage)
                    forgetView.delegate = self
                    self.view.backgroundColor = UIColor(netHex: 0x9E9E9E)
                }
            })
            
        }
    }
    
    func requestToServer(phone : String, mail : String, completion : ()->()) {
        let kForgetPasswordAPI = "http://api.30shine.com/customer/resetpassword"
        let parameters = ["Phone" : phone, "Email" : mail]
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            Alamofire.request(.POST, kForgetPasswordAPI, parameters: parameters, encoding: .JSON).responseJASON {
                response in
                if let json = response.result.value {
                    self.updateSuccess = json["d"].string == "success" ? true : false
                    completion()
                }
            }
        }
    }
    
    func setUserInteraction(status : Bool) {
        self.btnSubmit.userInteractionEnabled = status
        self.txtMail.userInteractionEnabled   = status
        self.txtPhone.userInteractionEnabled  = status
    }
    
    //MARK: Validation
    func validate(phone : String, email : String) -> Bool {
        return self.isValidEmail(email) && self.isPhoneValidate(phone)
    }
    
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    func isPhoneValidate(phone : String) -> Bool {
        if phone.characters.first != "0" {
            return false
        }
        if phone.characters.count < 10 && phone.characters.count > 11 {
            return false
        }
        return true
    }
    
}

extension ForgetPasswordController : ForgetAlertProtocol {
    func changeColor() {
        self.view.backgroundColor = UIColor.whiteColor()
    }
}
