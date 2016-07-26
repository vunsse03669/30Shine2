//
//  DetailHairViewController.swift
//  30Shine
//
//  Created by Mr.Vu on 7/25/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class DetailHairViewController: UIViewController {
    
    @IBOutlet weak var lblOther: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvSmallImage3: UIImageView!
    @IBOutlet weak var imvSmallImage2: UIImageView!
    @IBOutlet weak var imvSmallImage1: UIImageView!
    @IBOutlet weak var imvBigImage: UIImageView!
    @IBOutlet weak var clvMenu: UICollectionView!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var clvOtherHair: UICollectionView!
    
    var menuVar : Variable<[HairType]> = Variable([])
    var otherHairVar : Variable<[Imagee]> = Variable([])
    var index : Variable<Int> = Variable(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.configCollectionView()
        self.bindingData()

        _ = btnHome.rx_tap
            .subscribeNext {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    //MARK: UI
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        self.clvMenu.userInteractionEnabled = true
        self.configCollectionLayout()
    }
    
    //MARK: Collection view
    func configCollectionView() {
        _ = self.menuVar.asObservable().bindTo(self.clvMenu.rx_itemsWithCellIdentifier("MenuCollectionViewCell", cellType: MenuCollectionViewCell.self)) {row,data,cell in
            _ = self.index.asObservable().subscribeNext {
                index in
                if data.title == self.menuVar.value[index].title {
                    cell.lblTitle.font = UIFont.boldSystemFontOfSize(13)
                }
                else {
                    if #available(iOS 8.2, *) {
                        cell.lblTitle.font = UIFont.systemFontOfSize(13, weight: UIFontWeightThin)
                    }
                }
            }
            
            cell.lblTitle.text = "\(data.title)"
        }
        
        _ = self.clvMenu.rx_itemSelected.subscribeNext {
            indexPath in
            self.index.value = indexPath.row
            self.bindingData()
        }
        
        _ = self.otherHairVar.asObservable().bindTo(self.clvOtherHair.rx_itemsWithCellIdentifier("OtherHairCollectionViewCell", cellType: OtherHairCollectionViewCell.self)) {row,data,cell in
            LazyImage.showForImageView(cell.imvHair, url: data.imageUrl)
        }
    }
    
    func configCollectionLayout() {
        self.view.layoutIfNeeded()
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let width = self.view.bounds.width/3
        let height = self.clvMenu.bounds.height
        layout.itemSize = CGSizeMake(width, height)
        layout.scrollDirection = .Horizontal
        self.clvMenu.setCollectionViewLayout(layout, animated: true)
        
        let layoutHair : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutHair.minimumLineSpacing = 2
        layoutHair.minimumInteritemSpacing = 2
        layoutHair.sectionInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        let w = self.view.bounds.width/4
        let h = self.clvOtherHair.bounds.height
        layoutHair.itemSize = CGSizeMake(w, h)
        layoutHair.scrollDirection = .Horizontal
        self.clvOtherHair.setCollectionViewLayout(layoutHair, animated: true)
    }
    
    //MARK: Data
    func bindingData() {
        self.lblTitle.text = "\(self.menuVar.value[index.value].title)"
        self.lblDescription.text = "\(self.menuVar.value[index.value].script)"
        self.lblOther.text = "Các biến thể kiểu tóc \(self.menuVar.value[index.value].title)"
        
        let bigImageUrl = self.menuVar.value[index.value].images[0].imageUrl
        let smallImage1Url = self.menuVar.value[index.value].images[1].imageUrl
        let smallImage2Url = self.menuVar.value[index.value].images[2].imageUrl
        let smallImage3Url = self.menuVar.value[index.value].images[3].imageUrl
        LazyImage.showForImageView(self.imvBigImage, url: bigImageUrl)
        LazyImage.showForImageView(self.imvSmallImage1, url: smallImage1Url)
        LazyImage.showForImageView(self.imvSmallImage2, url: smallImage2Url)
        LazyImage.showForImageView(self.imvSmallImage3, url: smallImage3Url)
        
        self.matchingDataForOtherHair(self.index.value)
    }
    
    func matchingDataForOtherHair(index : Int) {
        self.otherHairVar.value = []
        var count = 0
        for image in self.menuVar.value[index].images {
            if count > 3 {
                self.otherHairVar.value.append(image)
            }
            count += 1
        }
    }
}
