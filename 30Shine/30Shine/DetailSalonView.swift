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
import Alamofire
import RealmSwift

class DetailSalonView: UIView , UIScrollViewDelegate, UIGestureRecognizerDelegate{
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
    @IBOutlet weak var clvTabs: UICollectionView!
    
    var salonVariable  : Variable<[Salon]> = Variable([])
    var salon : Salon = Salon()
    var currentIndex :Variable<Int> = Variable(0)
    var currentImgID = 0
    
    static func createInView(view: UIView) -> DetailSalonView{
        let detailSalonView = NSBundle.mainBundle().loadNibNamed("DetailSalonView", owner: self, options: nil) [0] as! DetailSalonView
        view.layoutIfNeeded()
        detailSalonView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        
        view.addSubview(detailSalonView)
        detailSalonView.alpha = 0
        UIView .animateWithDuration(0.2) {
            detailSalonView.alpha = 1
        }
        
        detailSalonView.setupButtons()
        detailSalonView.setupPichImageMap()
        detailSalonView.initData()
        return detailSalonView
    }
    
    func setupButtons(){
        self.setupImageTap()
        //btn.imageView.setContentMode:UIViewContentModeScaleAspectFit;
        btnBooking.imageView?.contentMode = .ScaleAspectFit
        btnFanpage.imageView?.contentMode = .ScaleAspectFit
        btnHotLine.imageView?.contentMode = .ScaleAspectFit
        
        _=btnHotLine.rx_tap.subscribeNext({
            print("hotline")
            //UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(self.salon.phone)")!)
        })
        
        _=btnBooking.rx_tap.subscribeNext({
            print("booking")
        })
        
        _=btnFanpage.rx_tap.subscribeNext({
            print("fanpage")
            
            if let url = NSURL(string: self.salon.fanpage) {
                UIApplication.sharedApplication().openURL(url)
            }
        })
    }
    
    func setupImageTap(){
        
        self.imvSalon1.tag = 1000
        self.imvSalon2.tag = 2000
        self.imvSalon3.tag = 3000
        self.imvMap   .tag = 4000
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.imvSalon1.userInteractionEnabled = true
        self.imvSalon1.addGestureRecognizer(tapGestureRecognizer1)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.imvSalon2.userInteractionEnabled = true
        self.imvSalon2.addGestureRecognizer(tapGestureRecognizer2)
        
        let tapGestureRecognizer3 = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.imvSalon3.userInteractionEnabled = true
        self.imvSalon3.addGestureRecognizer(tapGestureRecognizer3)
        
        let tapGestureRecognizer4 = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.imvMap.userInteractionEnabled = true
        self.imvMap.addGestureRecognizer(tapGestureRecognizer4)
        
        let doubleTapZoom = UITapGestureRecognizer(target: self, action: #selector(doubleTapToZoom))
        doubleTapZoom.numberOfTapsRequired = 2
        self.imvSelected.userInteractionEnabled = true
        self.imvSelected.addGestureRecognizer(doubleTapZoom)
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
            case 4000:
                self.currentImgID = 3
                break
            default:
                self.currentImgID = 0
                break
            }
            if(self.currentImgID < 3 && self.currentImgID >= 0){
                self.scrollView.zoomScale = 1
                self.scrollView.userInteractionEnabled = false
            }
            else{
                self.scrollView.userInteractionEnabled = true
            }
            // print("current id \(self.currentImgID)")
            LazyImage.showForImageView(imvSelected, url: salon.listImages[self.currentImgID].url)
        }
    }
    
    func setupPichImageMap(){
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = 5.0;
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imvSelected
    }
    
    func doubleTapToZoom(gesture : UIGestureRecognizer){
        
        if(self.currentImgID != 3){
            return
        }
        if(self.scrollView.zoomScale == 1){
            print("Zoom in")
            self.scrollView.setZoomScale(2, animated: true)
        }
        else{
            print("Zoom out")
            self.scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func initData(){
        parseJsonSalonSystem {
            () in
            self.bindingData()
            self.setupCollectionView()
        }
    }
    
    func setupCollectionView(){
        self.clvTabs.registerNib(UINib.init(nibName: "AddressTabCell", bundle: nil), forCellWithReuseIdentifier: "AddressTabCell")
        
        //config layout
        let flowLayout: UICollectionViewFlowLayout! = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        let width = self.clvTabs.frame.width/2.5
        let height = self.clvTabs.frame.height - 4
        flowLayout.itemSize = CGSizeMake(width, height)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.scrollDirection = .Horizontal
        self.clvTabs.setCollectionViewLayout(flowLayout, animated: false)
        
        //datasource
        dispatch_async(dispatch_get_main_queue()){
            _ = self.salonVariable.asObservable().bindTo(self.clvTabs.rx_itemsWithCellIdentifier("AddressTabCell", cellType: AddressTabCell.self)){
                row, data, cell in
                //selected cell
                _ = self.currentIndex.asObservable().subscribeNext {
                    index in
                    if data.name == self.salonVariable.value[index].name {
                        cell.lblAddress.font = UIFont.boldSystemFontOfSize(13)
                    }
                    else {
                        if #available(iOS 8.2, *) {
                            cell.lblAddress.font = UIFont.systemFontOfSize(13, weight: UIFontWeightThin)
                        }
                    }
                }
                
                cell.lblAddress.text = data.name
            }
        }
        _ = self.clvTabs.rx_itemSelected.subscribeNext {
            indexPath in
            self.currentIndex.value = indexPath.row
            self.bindingData()
        }
    }
    
    func bindingData(){
        self.salon = salonVariable.value[currentIndex.value]
        //self.lblAddress.text = salon.name
        if(salon.listImages.count >= 4){
            LazyImage.showForImageView(imvSelected, url: salon.listImages[0].url,defaultImage: IMG_DEFAULT)
            LazyImage.showForImageView(imvSalon1, url: salon.listImages[0].thumb,defaultImage: IMG_DEFAULT)
            LazyImage.showForImageView(imvSalon2, url: salon.listImages[1].thumb,defaultImage: IMG_DEFAULT)
            LazyImage.showForImageView(imvSalon3, url: salon.listImages[2].thumb,defaultImage: IMG_DEFAULT)
            LazyImage.showForImageView(imvMap, url: salon.listImages[3].url,defaultImage: IMG_DEFAULT)
            
            self.scrollView.userInteractionEnabled = false
            self.scrollView.zoomScale = 1
        }
    }
    
    
    func parseJsonSalonSystem(complete:()->()){
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let parameter = ["Id": 2]
            Alamofire.request(.POST, SALON_LIST_API,parameters: parameter,encoding: .JSON).responseJASON { response in
                if let json = response.result.value {
                    let salons = json["d"].map(SalonNetwork.init)
                    for salon in salons {
                        
                        if salon.ID != 6 { //hard
                            
                            let listImages : List<ImageObject> = List<ImageObject>()
                            for salonIN in salon.images {
                                let newSalonImage:ImageObject = ImageObject.create(salonIN.url, thumb: salonIN.thumb, title: salonIN.title, img_description: salonIN.img_description)
                                listImages.append(newSalonImage)
                            }
                            let newSalon : Salon = Salon.create(salon.ID, name: salon.name, phone: salon.phone, managerName: salon.managerName, fanpage: salon.fanpage, listImages: listImages)
                            self.salonVariable.value.append(newSalon)
                        }
                    }
                    complete()
                }
            }
        }
    }
}
