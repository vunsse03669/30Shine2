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
import Alamofire
import SVProgressHUD

class ModificationCustomerInfoController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var txtYob: UITextField!
    @IBOutlet weak var txtMob: UITextField!
    @IBOutlet weak var txtDob: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    
    var updateSuccess = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.bindingData()
        self.update()
        
        //Add hide keyboard observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

        
        //Add event for textfield
        self.txtDob.addTarget(self, action: #selector(handleTextField), forControlEvents: UIControlEvents.TouchDown)
        self.txtMob.addTarget(self, action: #selector(handleTextField), forControlEvents: UIControlEvents.TouchDown)
        self.txtYob.addTarget(self, action: #selector(handleTextField), forControlEvents: UIControlEvents.TouchDown)
        self.txtEmail.addTarget(self, action: #selector(handleEmail), forControlEvents: UIControlEvents.TouchDown)
    }
    
    //MARK: Add Calendar
    func handleTextField() {
        self.showCalendar()
    }
    
    func showCalendar() {
        let selector = CalendarView.createView(self.view)
        selector.delegate = self
    }
    
    //MARK: hide keyboard
    func keyboardWillShow(notification: NSNotification) {
        self.hideKeyboardWhenTappedAround()
    }
    
    func keyboardWillHide(notification: NSNotification) {
        for recognizer in view.gestureRecognizers ?? [] {
            view.removeGestureRecognizer(recognizer)
        }
        moveDownView(self.view)
    }

    
    func moveUpView(view : UIView){
        UIView.animateWithDuration(0.4) {
            view.transform = CGAffineTransformMakeTranslation(0, -CGFloat(HEIGHT_KEYBOARD))
        }
    }
    
    func moveDownView(view : UIView){
        UIView.animateWithDuration(0.4) {
            view.transform = CGAffineTransformIdentity
        }
    }
    
    func handleEmail() {
        moveUpView(self.view)
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
        
        //MARK: TextField
        self.configTextField(self.txtName, padding: 5.0, keyboardType: .Default)
        self.configTextField(self.txtPhone, padding: 5.0, keyboardType: .NumberPad)
        self.configTextField(self.txtEmail, padding: 5.0, keyboardType: .Default)
        self.configTextField(self.txtDob, padding: 5.0, keyboardType: .NumberPad)
        self.configTextField(self.txtMob, padding: 5.0, keyboardType: .NumberPad)
        self.configTextField(self.txtYob, padding: 5.0, keyboardType: .NumberPad)
        self.txtYob.inputView = UIView()
        self.txtMob.inputView = UIView()
        self.txtDob.inputView = UIView()

        
    }
    
    func configTextField(textField : UITextField, padding : CGFloat, keyboardType : UIKeyboardType) {
        textField.keyboardType = keyboardType
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(padding, 0, 0)
    }
    
    //MARK: Binding data
    func bindingData() {
        if Login.getLogin() != nil {
            let name  = Login.getLogin().fullName
            let phone = Login.getLogin().phone
            let email = Login.getLogin().email
            let dob   = Login.getLogin().dayOfbirth
            let mob   = Login.getLogin().monthOfBirth
            let yob   = Login.getLogin().yearOfBirth
            
            self.txtName.text  = name
            self.txtEmail.text = email
            self.txtPhone.text = phone
            self.txtDob.text   = "\(dob)"
            self.txtMob.text   = "\(mob)"
            self.txtYob.text   = "\(yob)"
        }
        
    }
    
    //MARK: Update
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func update() {
        _ = self.btnUpdate.rx_tap.subscribeNext {
            guard let phone = self.txtPhone.text, name = self.txtName.text, dob = Int(self.txtDob.text!), mob = Int(self.txtMob.text!), yob = Int(self.txtYob.text!), mail = self.txtEmail.text else {
                self.showAlert("Thông báo",msg: "Quá trình cập nhật thông tin xảy ra sự cố. Quý khách vui lòng kiểm tra lại thông tin")
                return
            }
            let id    = Login.getLogin().id
            let token = Login.getLogin().acessToken
            
            if id == 0 || token == "" || phone == "" || name == "" {
                self.showAlert("Thông báo",msg: "Quá trình cập nhật thông tin xảy ra sự cố. Quý khách vui lòng kiểm tra lại thông tin")
                return
            }
            if phone.characters.first != "0" {
                self.showAlert("Thông báo",msg: "Số điện thoại phải bắt đầu băng số 0")
                return
            }
            if phone.characters.count < 10 && phone.characters.count > 11 {
                self.showAlert("Thông báo",msg: "Số điện thoại phải bao gồm 10 hoặc 11 chữ số")
                return
            }
            if !self.isValidEmail(mail) {
                self.showAlert("Thông báo",msg: "Quý khách chưa nhập mail đúng định dạng! Quý khác vui lòng nhập lại")
                return
            }
            
            //Activity indicator
            SVProgressHUD.showWithStatus("Đang tải dữ liệu")
            
            self.updateInfo(id, phone: phone, name: name, dob: dob, mob: mob, yob: yob, email: mail, token: token) {
                dispatch_async(dispatch_get_main_queue(), { 
                    SVProgressHUD.popActivity()
                })
                if self.updateSuccess {
                    Login.updateLogin(Login.getLogin(), name: name, phone: phone, email: mail, dob: dob, mob: mob, yob: yob)
                    self.showAlert("Thông báo",msg: "Cập nhật thông tin thành công")
                    self.navigationController?.popViewControllerAnimated(true)
                    print("............ :\(Login.getLogin())")
                }
                else {
                    self.showAlert("Thông báo",msg: "Quá trình cập nhật thông tin xảy ra sự cố. Quý khách vui lòng kiểm tra lại thông tin")
                }
            }
        }
    }
    
    func updateInfo(id : Int, phone : String, name : String, dob : Int, mob : Int, yob : Int, email : String, token : String, completion: () -> ()) {
        let API = "http://api.30shine.com/customer/updateinfo"
        let parameter = ["Id" : id,
                         "Phone" : phone,
                         "CustomerName" : name,
                         "DayOfBirth" : dob,
                         "MonthOfBirth" : mob,
                         "YearOfBirth" : yob,
                         "Email" : email,
                         "AccessToken" : token]
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            Alamofire.request(.POST, API, parameters: parameter as? [String : AnyObject], encoding: .JSON).responseJASON {
                response in
                if let json = response.result.value {
                    if json["d"].string == "success" {
                        self.updateSuccess = true
                    }
                    else {
                        self.updateSuccess = false
                    }
                    completion()
                }
            }
        }
    
    }
    
    func showAlert(title: String, msg : String) {
        let alert = UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: "Xác nhận")
        alert.show()
    }
}



//MARK: Calendar delegate
extension ModificationCustomerInfoController : CalendarDelegate {
    func didPickDate(date: NSDate) {
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        self.txtDob.text = "\(components.day)"
        self.txtMob.text = "\(components.month)"
        self.txtYob.text = "\(components.year)"
    }

}
