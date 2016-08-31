//
//  DetailHairViewController.swift
//  30Shine
//
//  Created by Mr.Vu on 7/25/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import RealmSwift
import ReachabilitySwift

class DetailHairViewController: UIViewController {
    
    @IBOutlet weak var lblOther: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvSmallImage4: UIImageView!
    @IBOutlet weak var imvSmallImage3: UIImageView!
    @IBOutlet weak var imvSmallImage2: UIImageView!
    @IBOutlet weak var imvSmallImage1: UIImageView!
    @IBOutlet weak var imvBigImage: UIImageView!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var clvOtherHair: UICollectionView!
    
    var menuVar : Variable<HairType!> = Variable(nil)
    var otherHairVar : Variable<[Imagee]> = Variable([])
    var reachability : Reachability?
    var isConnectInternet = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.initData()
        
        _ = btnHome.rx_tap
            .subscribeNext {
                self.navigationController?.popViewControllerAnimated(true)
        }
        //Click btnProfile
        _ = btnProfile.rx_tap.subscribeNext {
            if self.isLogin() {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SelectProfileController") as! SelectProfileController
                self.navigationController?.push(vc, animated: true)
            }
            else {
                self.showAlert("Bạn chưa đăng nhập", message: "Mời quý khách đăng nhập/đăng ký tài khoản để sử dụng đầy đủ chức năng của ứng dụng!")
            }
        }
        
    }
    
    //MARK: UI
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        self.configCollectionLayout()
    }
    
    //MARK: Collection view
    func configCollectionView() {
        _ = self.otherHairVar.asObservable().bindTo(self.clvOtherHair.rx_itemsWithCellIdentifier("OtherHairCollectionViewCell", cellType: OtherHairCollectionViewCell.self)) {row,data,cell in
            LazyImage.showForImageView(cell.imvHair, url: data.imageUrl)
            if self.isConnectInternet {
                self.showAndDownloadImage(cell.imvHair, url: data.imageUrl, name: data.imageUrl)
            }
            else {
                cell.imvHair.image = UIImage(contentsOfFile: self.getImagePathFromDisk(data.imageUrl))
            }
            
        }
        
        _ = self.clvOtherHair.rx_itemSelected.subscribeNext {
            indexPath in
            if self.isConnectInternet {
                self.showAndDownloadImage(self.imvBigImage, url: self.otherHairVar.value[indexPath.row].imageUrl, name: self.otherHairVar.value[indexPath.row].imageUrl)
            }
            else {
                self.imvBigImage.image = UIImage(contentsOfFile: "\(self.getImagePathFromDisk(self.otherHairVar.value[indexPath.row].imageUrl))")
            }
        }
    }
    
    func configCollectionLayout() {
        self.view.layoutIfNeeded()
        let layoutHair : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutHair.minimumLineSpacing = 2
        layoutHair.minimumInteritemSpacing = 2
        layoutHair.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        let w = self.view.bounds.width/4
        let h = self.clvOtherHair.bounds.height - 10
        layoutHair.itemSize = CGSizeMake(w, h)
        layoutHair.scrollDirection = .Horizontal
        self.clvOtherHair.setCollectionViewLayout(layoutHair, animated: true)
    }
    
    //MARK: Data
    func bindingData() {
        if menuVar.value != nil {
            self.lblTitle.text = "\(self.menuVar.value.title)"
            self.lblDescription.text = "\(self.menuVar.value.script)"
            self.lblOther.text = "Các biến thể kiểu tóc \(self.menuVar.value.title)"
            
            let bigImageUrl = self.menuVar.value.images[0].imageUrl
            let smallImage1Url = self.menuVar.value.images[0].imageUrl
            let smallImage2Url = self.menuVar.value.images[1].imageUrl
            let smallImage3Url = self.menuVar.value.images[2].imageUrl
            let smallImage4Url = self.menuVar.value.images[3].imageUrl
            
            if self.isConnectInternet {
                self.showAndDownloadImage(self.imvBigImage, url: bigImageUrl, name: bigImageUrl)
                self.showAndDownloadImage(self.imvSmallImage1, url: smallImage1Url, name: smallImage1Url)
                self.showAndDownloadImage(self.imvSmallImage2, url: smallImage2Url, name: smallImage2Url)
                self.showAndDownloadImage(self.imvSmallImage3, url: smallImage3Url, name: smallImage3Url)
                self.showAndDownloadImage(self.imvSmallImage4, url: smallImage4Url, name: smallImage4Url)
            }
            else {
                self.imvBigImage.image = UIImage(contentsOfFile: self.getImagePathFromDisk("\(bigImageUrl)"))
                self.imvSmallImage1.image = UIImage(contentsOfFile: self.getImagePathFromDisk("\(smallImage1Url)"))
                self.imvSmallImage2.image = UIImage(contentsOfFile: self.getImagePathFromDisk("\(smallImage2Url)"))
                self.imvSmallImage3.image = UIImage(contentsOfFile: self.getImagePathFromDisk("\(smallImage3Url)"))
                self.imvSmallImage4.image = UIImage(contentsOfFile: self.getImagePathFromDisk("\(smallImage4Url)"))
            }
            self.matchingDataForOtherHair()
            self.tapOnImage(self.imvSmallImage1, url: smallImage1Url)
            self.tapOnImage(self.imvSmallImage2, url: smallImage2Url)
            self.tapOnImage(self.imvSmallImage3, url: smallImage3Url)
            self.tapOnImage(self.imvSmallImage4, url: smallImage4Url)
        }
    }
    
    
    
    func matchingDataForOtherHair() {
        self.otherHairVar.value = []
        var count = 0
        for image in self.menuVar.value.images {
            if count > 3 {
                self.otherHairVar.value.append(image)
            }
            count += 1
        }
    }
    
    //MARK: tap on image
    func tapOnImage(image : UIImageView, url : String) {
        image.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init()
        _ = tapGesture.rx_event.subscribeNext {
            gesture in
            self.showAndDownloadImage(self.imvBigImage, url: url, name: url)
        }
        image.addGestureRecognizer(tapGesture)
    }
    
    //MARK: Dump data
    func initData() {
        do {
            reachability = try! Reachability.reachabilityForInternetConnection()
        }
        reachability!.whenReachable = {
            reachability in
            self.isConnectInternet = true
        }
        reachability!.whenUnreachable = {
            reachability in
            self.isConnectInternet = false
        }
        try! reachability?.startNotifier()
        self.bindingData()
        self.configCollectionView()
    }
}

//MARK: Save Image To document
extension DetailHairViewController {
    func showAndDownloadImage(imageView: UIImageView, url: String, name : String) {
        LazyImage.showForImageView(imageView, url: url) {
            let newName = name.stringByReplacingOccurrencesOfString("/", withString: "")
            if let dataa = UIImageJPEGRepresentation(imageView.image!, 0.8) {
                let filename = self.getDocumentsDirectory().stringByAppendingPathComponent(newName)
                dataa.writeToFile(filename, atomically: true)
            }
        }
    }
    
    func getImagePathFromDisk(name : String) -> String {
        let newName = name.stringByReplacingOccurrencesOfString("/", withString: "")
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let getImagePath = paths.stringByAppendingString("/\(newName)")
        return getImagePath
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}

extension DetailHairViewController : UIAlertViewDelegate {
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
