//
//  CosmeticViewController.swift
//  30Shine
//
//  Created by Mr.Vu on 8/4/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class CosmeticViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var btnBack: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        webView.delegate = self
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://30shinestore.com/")!))
        
        _ = btnBack.rx_tap.subscribeNext {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationController?.navigationBar.translucent = false
        
        //profile image
        var profileImage = UIImage(named: "img-people")
        profileImage = profileImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: profileImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleProfile))
    }
    
    func handleProfile() {
        if self.isLogin() {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SelectProfileController") as! SelectProfileController
            self.navigationController?.push(vc, animated: true)
        }
        else {
            self.showAlert("Bạn chưa đăng nhập", message: "Mời quý khách đăng nhập/đăng ký tài khoản để sử dụng đầy đủ chức năng của ứng dụng!")
        }
    }

    
    //MARK: Webview delegate
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }



}

extension CosmeticViewController : UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginController") as! LoginController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showAlert(title : String, message : String) {
        let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "Để sau", otherButtonTitles: "Đăng nhập")
        alert.show()
    }
}
