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
    var currentSalon = Salon()
    var salonVariable  : Variable<[ImageObject]> = Variable([])
    var currentIndex :Variable<Int> = Variable(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPichImageMap()
        setupData()
        setupCollectionView()
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
        
        //config layout
        let flowLayout: UICollectionViewFlowLayout! = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 10

        self.clvImagesList.layoutIfNeeded()
        
        let height = self.view.bounds.height
        print(height)
        let width = height
        
        flowLayout.itemSize = CGSizeMake(width, height)
        
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
