//
//  RegisterViewController.swift
//  30Shine
//
//  Created by Đỗ Ngọc Trình on 8/12/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import Alamofire
import JASON
import Alamofire

class RegisterViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var lblWarning: UILabel!
    @IBOutlet weak var textPhone: UITextField!
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var textDate: UITextField!
    @IBOutlet weak var textMonth: UITextField!
    @IBOutlet weak var textYear: UITextField!
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textConfirmPass: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CHƯa CHECK EAMAIL")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        setUpButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpButton(){
        
        setTagForTextField()
        
        _ = btnRegister.rx_tap.subscribeNext{
            print(" register ");
            if(self.validate()){
                let date : Int? = Int(self.textDate.text!)
                let month : Int? = Int(self.textMonth.text!)
                let year : Int? = Int(self.textYear.text!)
                print(date)
                self.sendRequest(self.textPhone.text!, customerName: self.textName.text!, email: self.textEmail.text!, password: self.textPassword.text!, dayOfBirth: date!, monthOfBirth: month!, yearOfBirth: year!, completion: {
                    
                })
            }else{
                // self.showAlert("Cảnh báo", msg: "Vui lòng kiểm tra lại thông tin đăng kí")
            }
        }
    }
    
    func setTagForTextField(){
        textPhone.tag = 0
        textName.tag = 1
        textDate.tag = 2
        textMonth.tag = 3
        textYear.tag = 4
        textPassword.tag = 5
        textConfirmPass.tag = 6
        
        textPhone.delegate = self
        textName.delegate = self
        textDate.delegate = self
        textMonth.delegate = self
        textYear.delegate = self
        textPassword.delegate = self
        textConfirmPass.delegate = self
        textEmail.delegate = self
    }
    
    let RANGE_AFTER = 10
    let RANGE_BEFORE = 11
    let PASSWORD_MINLETTER = 4
    
    func validate() -> Bool{
        //check empty
        if(!self.checkNoEmptyTextFieldIn(self.view)){
            self.showAlert("Đăng kí", msg: "Vui lòng điền đầy đủ thông tin")
            return false
        }
        
        //valid phone number
        print("leng phone : \(self.textPhone.text?.length)")
        if(self.textPhone.text?.length < RANGE_AFTER || self.textPhone.text?.length>RANGE_BEFORE){
            self.showAlert("Đăng kí", msg: "Số điện thoại chỉ bao gồm 10 hoặc 11 số");
            return false
        }
        
        //valid phone number
        if(self.textPhone.text?.length>0){
            print(self.textPhone.text?.hasPrefix("0"))
            if((self.textPhone.text?.hasPrefix("0")) == false){
                self.showAlert("Đăng kí", msg: "Số điện thoại phải bắt đầu với số 0");
                return false;
            }
        }
        
        //minimum leter of pass
        if(self.textPassword.text?.length < PASSWORD_MINLETTER){
            self.showAlert("Đăng kí", msg: "Mật khẩu phải có ít nhất \(PASSWORD_MINLETTER) kí tự");
            return false
        }
        
        //compare confirm password
        if(self.textPassword.text != self.textConfirmPass.text){
            self.showAlert("Đăng kí", msg: "Mật khẩu và xác nhận mật khẩu không trùng khớp")
            return false
        }
        
        return true
    }
    
    //MARK: hide keyboard
    func keyboardWillShow(notification: NSNotification) {
        self.hideKeyboardWhenTappedAround()
        // self.moveUpView(self.view)
    }
    
    func moveUpView(view : UIView){
        UIView.animateWithDuration(0.6) {
            view.transform = CGAffineTransformMakeTranslation(0, -CGFloat(HEIGHT_KEYBOARD))
        }
    }
    func moveDownView(view : UIView){
        UIView.animateWithDuration(0.6) {
            view.transform = CGAffineTransformIdentity
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        for recognizer in view.gestureRecognizers ?? [] {
            view.removeGestureRecognizer(recognizer)
        }
        self.moveDownView(self.view)
    }
    
    //MARK: Send request to server
    func sendRequest(phone : String, customerName : String, email: String,password : String, dayOfBirth:Int, monthOfBirth: Int, yearOfBirth: Int,completion :()->()) {
        let parameter  = ["Phone" : phone,
                          "CustomerName" : customerName,
                          "Email" : email,
                          "Password" : password,
                          "DayOfBirth" : NSNumber(integer: dayOfBirth),
                          "MonthOfBirth" : NSNumber(integer: monthOfBirth),
                          "YearOfBirth" : NSNumber(integer: yearOfBirth)]
        
        let API = "http://api.30shine.com/customer/register"
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            Alamofire.request(.POST, API, parameters: parameter , encoding: .JSON).responseJASON {
                response in
                if let json = response.result.value {
                    let loginNetwork = LoginNetwork.init(json["d"])
                    print(loginNetwork)
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
                        // self.loginSuccess = false
                        print("FALSE")
                        self.showAlert("", msg: "Đăng kí không thành công")
                    }
                    else {
                        //self.loginSuccess = true
                        print("TRUE")
                        self.showAlert("", msg: "Đăng kí thành công")
                        
                        //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                        //self.navigationController?.pushViewController(vc, animated: true)
                        
                    }
                    completion()
                }
            }
        }
    }
    
    func enableRegisterButton(){
        self.btnRegister.enabled = true
    }
    
    func disableRegisterButton(){
        self.btnRegister.enabled = false
    }
    
    func checkNoEmptyTextFieldIn(view: UIView) -> Bool{
        
        for view in view.subviews {
            if view.isKindOfClass(UITextField) {
                if((view as! UITextField).text?.characters.count == 0){
                    return false
                }
            }
        }
        return true
    }
    
    
    func setMaxLength(maxLength: Int, textField : UITextField){
        if(textField.text?.length >= maxLength){
            let str = textField.text!
            textField.text = str.substringWithRange(Range<String.Index>(str.startIndex ..< str.startIndex.advancedBy(maxLength-1)))
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var maxLength : Int!
        switch textField.tag {
        case 0:
            maxLength = RANGE_BEFORE
            break
        case 2,3:
            maxLength = 2
            
        case 4:
            maxLength = 4
        default:
            maxLength = 255
            break
        }
        
        self.setMaxLength(maxLength, textField: textField)
        
        return true
    }
    
    func showAlert(title : String, msg : String) {
        let alert = UIAlertView(title: title, message: msg, delegate: self, cancelButtonTitle: "Xác nhận")
        alert.show()
    }
}
