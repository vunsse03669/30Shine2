//
//  ChainSystemViewController.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import NPSegmentedControl
import RxSwift
import RxCocoa
import Alamofire

class ChainSystemViewController: UIViewController {
    
    
    @IBOutlet weak var selector: NPSegmentedControl!
    
    
    //var listSalonView : ListSalonView!
    var detailView : DetailSalonView!
    var serviceView : ServiceView!
    
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSelector()
        setupContent()
        
    }
    
    func setupBarButton(){
        _ = btnHome.rx_tap
            .subscribeNext {
               // let vc = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                self.navigationController?.pop()
        }
        
        _ = btnProfile.rx_tap.subscribeNext {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SelectProfileController") as! SelectProfileController
            self.navigationController?.push(vc, animated: true)
        }
    }
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
    }
    
    func setupNavigationBar()
    {
        setupBarButton()
        configUI()
    }
    
    func setupSelector(){
        let myElements = ["Dịch Vụ","Hệ thống Salon"]
        
        let indicatorImage = UIImageView(image: UIImage(named: "tabindicator"))
        indicatorImage.image = indicatorImage.image?.imageWithRenderingMode(.AlwaysTemplate)
        indicatorImage.tintColor = UIColor(red: 240/255, green: 241/255, blue: 242/255, alpha: 1)
        selector.cursor = indicatorImage;
        let customFont = UIFont(name: "UTM-Alexander", size: 17)
        selector .unselectedFont = customFont;
        selector.selectedFont = customFont;
        selector.unselectedTextColor = UIColor(red: 137/255, green: 136/255, blue: 136/255, alpha: 1)
        selector.unselectedColor = UIColor(red: 240/255, green: 241/255, blue: 242/255, alpha: 1)
        selector.selectedTextColor = UIColor(red: 11/255, green: 11/255, blue: 11/255, alpha: 1)
        selector.selectedColor = UIColor(red: 240/255, green: 241/255, blue: 242/255, alpha: 1)
        selector.backgroundColor = .clearColor()
        selector.cursorPosition = CursorPosition.Bottom
        
        selector.setItems(myElements)
    }
    
    func setupContent(){
        //listSalonView = ListSalonView.createInView(contentView)
        detailView = DetailSalonView.createInView(contentView)
        serviceView = ServiceView.createInView(contentView)
    }
    
    @IBAction func selectorValueChange(sender: AnyObject) {
        if(selector.selectedIndex() == 0){
            print("Dich vu")
            UIView .animateWithDuration(0.2, animations: {
                self.detailView.alpha = 0
                self.serviceView.alpha = 1
            })
//            if(detailView != nil){
//                self.detailView.disappearDetail()
//            }
        }
        else{
            print("He thong")
            UIView .animateWithDuration(0.2, animations: {
                self.detailView.alpha = 1
                self.serviceView.alpha = 0
            })
//            if(detailView.detailSalonView != nil){
//                self.detailView.disappearDetail()
//            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
