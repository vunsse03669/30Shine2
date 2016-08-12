//
//  ProfileViewController.swift
//  30Shine
//
//  Created by Mr.Vu on 7/23/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import NPSegmentedControl

class ProfileViewController: UIViewController {
   
    @IBOutlet weak var vSelector: NPSegmentedControl!
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    
    var historyView : CustomerHistoryView!
    var currentTab = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.configContent()
        //self.configSelector()
        //back to home
        _ = btnHome.rx_tap
            .subscribeNext {
                //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
    }
    
    func configContent() {
        self.historyView = CustomerHistoryView.createView(self.vContainer)
    }
    
    //MARK: Selector
//    func configSelector(){
//        let myElements = ["Thông tin KH","Tin nhắn","Ảnh cá nhân","Lịch sử KH"]
//        
//        let indicatorImage = UIImageView(image: UIImage(named: "tabindicator"))
//        indicatorImage.image = indicatorImage.image?.imageWithRenderingMode(.AlwaysTemplate)
//        indicatorImage.tintColor = UIColor(red: 240/255, green: 241/255, blue: 242/255, alpha: 1)
//        self.vSelector.cursor = indicatorImage;
//        let customFont = UIFont(name: "UTM-Alexander", size: 13)
//        self.vSelector .unselectedFont = customFont;
//        self.vSelector.selectedFont = customFont;
//        self.vSelector.unselectedTextColor = UIColor(red: 137/255, green: 136/255, blue: 136/255, alpha: 1)
//        self.vSelector.unselectedColor = UIColor(red: 240/255, green: 241/255, blue: 242/255, alpha: 1)
//        self.vSelector.selectedTextColor = UIColor(red: 11/255, green: 11/255, blue: 11/255, alpha: 1)
//        self.vSelector.selectedColor = UIColor(red: 240/255, green: 241/255, blue: 242/255, alpha: 1)
//        self.vSelector.backgroundColor = .clearColor()
//        self.vSelector.cursorPosition = CursorPosition.Bottom
//        
//        self.vSelector.setItems(myElements)
//    }

    
    @IBAction func selectorValueChange(sender: AnyObject) {
//        if(self.vSelector.selectedIndex() == 0 && self.currentTab != 0){
//            self.currentTab = 0
//            //print("Dich vu")
////            UIView .animateWithDuration(0.2, animations: {
////                self.listSalonView.alpha = 0
////                self.serviceView.alpha = 1
////            })
////            if(listSalonView.detailSalonView != nil){
////                self.listSalonView.disappearDetail()
////            }
//        }
//        else if(self.vSelector.selectedIndex() == 3 && self.currentTab != 3) {
//            print("history")
//            self.currentTab = 3
//            self.removeSubView()
//            self.configContent()
////            UIView .animateWithDuration(0.2, animations: {
////                self.listSalonView.alpha = 1
////                self.serviceView.alpha = 0
////            })
////            if(listSalonView.detailSalonView != nil){
////                self.listSalonView.disappearDetail()
////            }
        
//        }

    }
    
    func removeSubView() {
        for view in self.vContainer.subviews {
            view.removeFromSuperview()
        }
    }
}
