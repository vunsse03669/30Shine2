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
    var currentImgID = 0
    
    static func createInView(view: UIView, contentSalon: Salon) -> DetailSalonView{
        let detailSalonView = NSBundle.mainBundle().loadNibNamed("DetailSalonView", owner: self, options: nil) [0] as! DetailSalonView
        view.layoutIfNeeded()
        detailSalonView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        
        view.addSubview(detailSalonView)
        detailSalonView.alpha = 0
        UIView .animateWithDuration(0.2) {
            detailSalonView.alpha = 1
        }
        detailSalonView.setupContent(contentSalon)
        detailSalonView.setupButtons()
        detailSalonView.setupPichImageMap()
        
        
        return detailSalonView
    }
    
    func setupButtons(){
        self.setupImageTap()
        
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
    
    func setupImageTap(){
        
        self.imvSalon1.tag = 1000
        self.imvSalon2.tag = 2000
        self.imvSalon3.tag = 3000
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.imvSalon1.userInteractionEnabled = true
        self.imvSalon1.addGestureRecognizer(tapGestureRecognizer1)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.imvSalon2.userInteractionEnabled = true
        self.imvSalon2.addGestureRecognizer(tapGestureRecognizer2)
        
        let tapGestureRecognizer3 = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.imvSalon3.userInteractionEnabled = true
        self.imvSalon3.addGestureRecognizer(tapGestureRecognizer3)
    }
    
    func imageTapped(gesture:UIGestureRecognizer)
    {
        
        if(salon.listImages.count >= 4){
            switch gesture.view!.tag {
            case 1000:
                self.currentImgID = 0
                break
            case 2000:
                self.currentImgID = 1
                break
            case 3000:
                self.currentImgID = 2
                break
            default:
                self.currentImgID = 0
                break
            }
            print("current id \(self.currentImgID)")
            LazyImage.showForImageView(imvSelected, url: salon.listImages[self.currentImgID].url)
        }
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
    
    func setupPichImageMap(){
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = 10.0;
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imvMap
    }
}
