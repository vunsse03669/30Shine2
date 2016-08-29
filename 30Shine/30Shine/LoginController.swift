//
//  LoginController.swift
//  30Shine
//
//  Created by Apple on 8/11/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import SVProgressHUD
import Firebase
import FirebaseMessaging
import FirebaseInstanceID

class LoginController: UIViewController, UIAlertViewDelegate {

    @IBOutlet weak var btnForgotPass: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    
    var loginSuccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.login()
        
        //push to Register VC
        _ = btnRegister.rx_tap.subscribeNext{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RegisterViewController") as! RegisterViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //push to Forget VC
        _ = btnForgotPass.rx_tap.subscribeNext{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ForgetPasswordController") as! ForgetPasswordController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: animated)
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
        self.txtPassword.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        self.txtPassword.secureTextEntry = true
        
        self.txtPhone.text = "01669808868"
        self.txtPassword.text = "api123"
    }
    //MARK: Login
    func login() {
        _ = btnLogin.rx_tap.subscribeNext {
            
            SVProgressHUD.showWithStatus("Đang tải dữ liệu")
            guard let phone = self.txtPhone.text, password = self.txtPassword.text else {
                return
            }
            //
            if !self.checkLogin(phone, password: password) {
                return
            }
            self.btnLogin.userInteractionEnabled = false
            self.sendRequest(phone, password: password, completion: {
                dispatch_async(dispatch_get_main_queue(), { 
                    SVProgressHUD.popActivity()
                })
                self.btnLogin.userInteractionEnabled = true
                if !self.loginSuccess {
                    self.showAlert("", msg: "Số điện thoại hoặc mật khẩu đăng nhập sai. Quý khách vui lòng kiểm tra lại")
                }
                else {
                    self.tokenRefreshNotification()
                    SendTokenNotification.shareInstance.sendTokenNotification({})
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
        
    }
    
    func tokenRefreshNotification() {
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
    
    func checkLogin(phone: String, password: String) -> Bool{
        if phone == "" {
            self.showAlert("", msg: "Quý khách vui lòng điền số điện thoại để đăng nhập thành công")
            return false
        }
        else if password == "" {
            self.showAlert("", msg: "Quý khách vui lòng điền mật khẩu để đăng nhập thành công")
            return false
        }
        else if phone == "" || password == "" {
            self.showAlert("", msg: "Quý khách vui lòng điền đầy đủ số điện thoại và mật khẩu để đăng nhập thành công")
            return false
        }
        else if phone.characters.first != "0" {
            self.showAlert("Cảnh báo",msg:"Số điện thoại phải bắt đầu băng số 0")
            return false
        }
        else if phone.characters.count < 10 && phone.characters.count > 11 {
            self.showAlert("Cảnh báo",msg:"Số điện thoải phải bao gồm 10 hoặc 11 chữ số")
            return false
        }
        
        return true
    }
    
    func showAlert(title : String, msg : String) {
        let alert = UIAlertView(title: title, message: msg, delegate: self, cancelButtonTitle: "Xác nhận")
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            SVProgressHUD.popActivity()
            self.btnLogin.userInteractionEnabled = true
        }
    }
    
    //MARK: Send request to server
    func sendRequest(phone : String, password : String, completion :()->()) {
        let parameter = ["Phone" : phone, "Password" : password]
        let API = "http://api.30shine.com/customer/login"
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            Alamofire.request(.POST, API, parameters: parameter, encoding: .JSON).responseJASON {
                response in
                if let json = response.result.value {
                    let loginNetwork = LoginNetwork.init(json["d"])
                    if Login.getLoginById(loginNetwork.id) == nil && loginNetwork.id != 0{
                        Login.create(loginNetwork.id, phone: loginNetwork.phone, fullName: loginNetwork.fullname,
                            email: loginNetwork.email, token: loginNetwork.accessToken, dob: loginNetwork.dob,
                            mob: loginNetwork.mob, yob: loginNetwork.yob)
                    }
                    else if (Login.getLoginById(loginNetwork.id) != nil) {
                        let login = Login.getLoginById(loginNetwork.id)
                        Login.updateToken(login, token: loginNetwork.accessToken)
                    }
                    if loginNetwork.id == 0 {
                        self.loginSuccess = false
                    }
                    else {
                        self.loginSuccess = true
                    }
                    completion()
                }
            }
        }
    }

}
