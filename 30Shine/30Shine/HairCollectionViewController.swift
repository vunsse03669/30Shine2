//
//  HairCollectionViewController.swift
//  30Shine
//
//  Created by Mr.Vu on 7/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import RealmSwift
import ReachabilitySwift
import SVProgressHUD

class HairCollectionViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var tbvHairType: UITableView!
    
    var hairTypeVariable : Variable<[HairType]> = Variable([])
    var reachability : Reachability?
    var isConnectInternet = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tbvHairType.scrollToRowAtIndexPath(NSIndexPath(forRow: HairIndex.shareInstance.getIndex(), inSection: 0), atScrollPosition: UITableViewScrollPosition.None, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.initData()
        self.tbvHairType.delegate = self
        HairIndex.shareInstance.setIndex(0)
        
        //back to home
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
    }
    
    //MARK: Tableview
    func configTableView() {
        _ = self.hairTypeVariable.asObservable().bindTo(self.tbvHairType.rx_itemsWithCellIdentifier("HairTypeCell", cellType: HairTypeCell.self)) {
            row,data,cell in
            cell.lblTitle.text = "\(data.title)"
            cell.lblDescription.text = "\(data.script)"

            self.showAndDownloadImage(cell.imvImage, url: data.images[0].imageUrl, imageName: data.images[0].imageUrl)
        }
    }
    
    //MARK: Dump data
    func initData() {
        
        do {
            reachability = try! Reachability.reachabilityForInternetConnection()
        }
        reachability!.whenReachable = {
            reachability in
            self.isConnectInternet = true
            dispatch_async(dispatch_get_main_queue()) {
                //Activity indicator
                SVProgressHUD.showWithStatus("Đang tải dữ liệu")
                self.hairTypeVariable.value = []
                self.parseJSON({ 
                    () in
                    dispatch_async(dispatch_get_main_queue(), { 
                        SVProgressHUD.popActivity()
                    })
                })
            }
        }
        reachability!.whenUnreachable = {
            reachability in
            self.isConnectInternet = false
            dispatch_async(dispatch_get_main_queue()) {
                self.hairTypeVariable.value = []
                self.hairTypeVariable.value = HairType.getAllHairType()
            }
        }
        self.configTableView()
        try! reachability?.startNotifier()
    }
    
    func parseJSON(complete: ()->()) {
        let HAIRTYPE_API = "http://api.30shine.com/hairstyle/index"
        let parameter = ["" : ""]
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            Alamofire.request(.POST,HAIRTYPE_API,parameters: parameter, encoding: .JSON).responseJASON {
                response in
                if let json = response.result.value {
                    let haiTypes = json["d"].map(HairNetwork.init)
                    for hairType in haiTypes {
                        let images = List<Imagee>()
                        for image in hairType.image {
                            if Imagee.getImageeByUrl(image.url) == nil {
                                images.append(Imagee.create(image.url))
                            }
                            else {
                                images.append(Imagee.getImageeByUrl(image.url))
                            }
                        }
                        if HairType.getHairTypeById(hairType.id) == nil {
                            let h = HairType.create(hairType.id, title: hairType.title, script: hairType.description, imageName: images)
                            self.hairTypeVariable.value.append(h)
                        }
                        else {
                            self.hairTypeVariable.value.append(HairType.getHairTypeById(hairType.id))
                        }
                    }
                    complete()
                }
            }
        }
    }

    //MARK: table delegate
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Insert
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tbvHairType.deselectRowAtIndexPath(indexPath, animated: false)
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DetailHairViewController") as! DetailHairViewController
        
        HairIndex.shareInstance.setIndex(indexPath.row)
        vc.menuVar.value = self.hairTypeVariable.value[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HairCollectionViewController {
    func showAndDownloadImage(imageView: UIImageView, url: String, imageName : String) {
        if self.isConnectInternet {
            LazyImage.showForImageView(imageView, url: url, defaultImage: IMG_DEFAULT, completion: {
                dispatch_async(dispatch_get_global_queue(0, 0), { 
                    let newName = imageName.stringByReplacingOccurrencesOfString("/", withString: "")
                    if let dataa = UIImageJPEGRepresentation(imageView.image!, 0.8) {
                        let filename = self.getDocumentsDirectory().stringByAppendingPathComponent(newName)
                        dataa.writeToFile(filename, atomically: true)
                    }

                })
            })
        }
        else {
            imageView.image = UIImage(contentsOfFile: self.getImagePathFromDisk(imageName))
        }
    }
    
    func getImagePathFromDisk(name : String) -> String {
        let newName = name.stringByReplacingOccurrencesOfString("/", withString: "")
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let getImagePath = paths.stringByAppendingString("/\(newName)")
        //self.imv.image = UIImage(contentsOfFile: getImagePath)
        return getImagePath
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}

extension HairCollectionViewController : UIAlertViewDelegate {
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


