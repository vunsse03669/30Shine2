//
//  DetailSalon.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DetailSalonView: UIView , UIScrollViewDelegate{
    
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var imvSelected: UIImageView!
    @IBOutlet weak var imvSalon1: UIImageView!
    @IBOutlet weak var imvSalon2: UIImageView!
    @IBOutlet weak var imvSalon3: UIImageView!
    
    @IBOutlet weak var imvMap: UIImageView!
    @IBOutlet weak var btnHotLine: UIButton!
    @IBOutlet weak var btnBooking: UIButton!
    @IBOutlet weak var btnFanpage: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var salon : Salon = Salon()
    
    static func createInView(view: UIView, contentSalon: Salon) -> DetailSalonView{
        let detailSalonView = NSBundle.mainBundle().loadNibNamed("DetailSalonView", owner: self, options: nil) [0] as! DetailSalonView
        view.layoutIfNeeded()
        detailSalonView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        
        view.addSubview(detailSalonView)
        detailSalonView.alpha = 0
        UIView .animateWithDuration(0.2) {
            detailSalonView.alpha = 1
        }
        detailSalonView.scrollView.minimumZoomScale = 1
        detailSalonView.scrollView.maximumZoomScale = 5
        detailSalonView.setupContent(contentSalon)
        detailSalonView.setupButtons()
        
        
        
        return detailSalonView
    }
    
    func setupButtons(){
        _=btnHotLine.rx_tap.subscribeNext({
            print("hotline")
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://0989740361")!)
        })
        
        _=btnBooking.rx_tap.subscribeNext({
            print("booking")
        })
        
        _=btnFanpage.rx_tap.subscribeNext({
            print("fanpage")
//            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
//                // Safe to launch the facebook app
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/200538917420"]];
//            }
            if(UIApplication .sharedApplication().canOpenURL(NSURL(string:"fb://")!)){
            
            }
//            } else
//            
//            if let url = NSURL(string: "https://www.hackingwithswift.com") {
//                UIApplication.sharedApplication().openURL(url)
//            }
        })
        
    }
    
    func setupContent(salon: Salon){
        self.salon = salon
        self.lblAddress.text = salon.name
        if(salon.listImages.count >= 4){
            print("\(salon.listImages[3].thumb)")
            LazyImage.showForImageView(imvSelected, url: salon.listImages[0].url)
            LazyImage.showForImageView(imvSalon1, url: salon.listImages[0].thumb)
            LazyImage.showForImageView(imvSalon2, url: salon.listImages[1].thumb)
            LazyImage.showForImageView(imvSalon3, url: salon.listImages[2].thumb)
            LazyImage.showForImageView(imvMap, url: salon.listImages[3].url)
        }
        
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imvMap
    }
    
}
