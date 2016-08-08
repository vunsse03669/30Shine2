//
//  DetailSalonViewController.swift
//  30Shine
//
//  Created by Đỗ Ngọc Trình on 8/7/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DetailSalonViewController: UIViewController,UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var imvSelected: UIImageView!
    @IBOutlet weak var clvImagesList: UICollectionView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var btnHotline: UIButton!
    @IBOutlet weak var btnBooking: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    
    var currentSalon = Salon()
    var salonVariable  : Variable<[ImageObject]> = Variable([])
    var currentIndex :Variable<Int> = Variable(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupPichImageMap()
        setupData()
        setupCollectionView()
        setupButtons()
    }
    
    func setupData(){
        self.lblAddress.text = currentSalon.name
        LazyImage.showForImageView(self.imvSelected, url: currentSalon.listImages[0].url)
        for img in currentSalon.listImages {
            salonVariable.value.append(img)
        }
        
        let doubleTapZoom = UITapGestureRecognizer(target: self, action: #selector(doubleTapToZoom))
        doubleTapZoom.numberOfTapsRequired = 2
        self.imvSelected.userInteractionEnabled = true
        self.imvSelected.addGestureRecognizer(doubleTapZoom)
        
    }
    
    func setupCollectionView(){
        self.clvImagesList.registerNib(UINib.init(nibName: "SalonImageCell", bundle: nil), forCellWithReuseIdentifier: "SalonImageCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        
        //config layout

        self.view.layoutIfNeeded()
        self.clvImagesList.layoutIfNeeded()
        
        let height = self.clvImagesList.bounds.height - 80
        print(height)
        let width = height*4/3
        let space = 5.0 as CGFloat
        
        // Set view cell size
        flowLayout.itemSize = CGSizeMake(width,height)
        
        // Set left and right margins
        flowLayout.minimumInteritemSpacing = space
        
        // Set top and bottom margins
        flowLayout.minimumLineSpacing = space
        
        flowLayout.scrollDirection = .Horizontal
        self.clvImagesList.setCollectionViewLayout(flowLayout, animated: false)
        
        self.clvImagesList.showsHorizontalScrollIndicator = false
        
        //datasource
        dispatch_async(dispatch_get_main_queue()){
            _ = self.salonVariable.asObservable().bindTo(self.clvImagesList.rx_itemsWithCellIdentifier("SalonImageCell", cellType: SalonImageCell.self)){
                row, data, cell in
                //selected cell
                LazyImage.showForImageView(cell.imvSalon, url: data.thumb)
            }
        }
        _ = self.clvImagesList.rx_itemSelected.subscribeNext {
            indexPath in
            self.currentIndex.value = indexPath.row
            if(self.currentIndex.value < 3 && self.currentIndex.value >= 0){
                self.scrollView.zoomScale = 1
                self.scrollView.userInteractionEnabled = false
            }
            else{
                self.scrollView.userInteractionEnabled = true
            }
            LazyImage.showForImageView(self.imvSelected, url: self.currentSalon.listImages[self.currentIndex.value].url)
        }
    }
    
    func setupButtons(){
       
        //btn.imageView.setContentMode:UIViewContentModeScaleAspectFit;
        btnBooking.imageView?.contentMode = .ScaleAspectFit
        btnFacebook.imageView?.contentMode = .ScaleAspectFit
        btnFacebook.imageView?.contentMode = .ScaleAspectFit
        
        _=btnFacebook.rx_tap.subscribeNext({
            print("hotline")
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(self.currentSalon.phone)")!)
        })
        
        _=btnBooking.rx_tap.subscribeNext({
            print("booking")
            
        })
        
        _=btnFacebook.rx_tap.subscribeNext({
            print("fanpage")
            
            if let url = NSURL(string: self.currentSalon.fanpage) {
                UIApplication.sharedApplication().openURL(url)
            }
        })
    }

    
    func setupPichImageMap(){
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = 5.0;
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imvSelected
    }
    
    func doubleTapToZoom(gesture : UIGestureRecognizer){
        
        if(self.currentIndex.value != 3){
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
