//
//  ServiceView.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ServiceView: UIView {
    @IBOutlet weak var btnShineCombo: UIButton!
    @IBOutlet weak var btnOtherServices: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    var currentIndex : Int = 0
    var shineComboView : ShineComboView!
    var otherservicesView : OtherServicesView!
    
    static func createInView(view: UIView) -> ServiceView{
        let serviceView : ServiceView = NSBundle.mainBundle().loadNibNamed("ServiceView", owner: self, options: nil)[0] as! ServiceView
        
        serviceView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        view.addSubview(serviceView)
        
        serviceView.alpha = 0;
        UIView .animateWithDuration(0.2) {
            serviceView.alpha = 1
        }
        
        serviceView.setupButton()
        serviceView.setupContent()
        serviceView.updateUI()
        
        return serviceView
    }
    
    func setupButton(){
        configUI()
        _ = btnShineCombo.rx_tap.subscribeNext({
            if(self.currentIndex == 0){
                return
            }
            self.currentIndex = 0
            self.updateUI()
        })
        _ = btnOtherServices.rx_tap.subscribeNext({
            if(self.currentIndex == 1){
                return
            }
            self.currentIndex = 1
            self.updateUI()
        })
    }
    
    func setupContent(){
        self.shineComboView = ShineComboView.createInView(self.contentView)
        self.otherservicesView = OtherServicesView.createInView(self.contentView)
    }
    
    func updateUI(){
        if(currentIndex == 0){
            self.btnShineCombo.tintColor = .blackColor()
            self.btnOtherServices.tintColor = .grayColor()
            self.shineComboView.fadeIn(0.1)
            self.otherservicesView.fadeOut(0.1)
            
        }
        else{
            self.btnOtherServices.tintColor = .blackColor()
            self.btnShineCombo.tintColor = .grayColor()
            self.otherservicesView .fadeIn(0.1)
            self.shineComboView.fadeOut(0.1)
        }
        
        
    }
    func configUI(){
        self.btnShineCombo.titleLabel?.font = UIFont(name: "UTM-Alexander", size: 14)
        self.btnOtherServices.titleLabel?.font = self.btnShineCombo.titleLabel?.font
        
        self.btnShineCombo.setTitle("Shine Combo", forState: UIControlState.Normal)
        self.btnOtherServices.setTitle("Dịch Vụ Khác", forState: UIControlState.Normal)
        
        self.btnOtherServices.tintColor = .blackColor()
        self.btnShineCombo.tintColor = .blackColor()
    }
    
}
