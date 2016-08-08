//
//  ShineCombo.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire
import RealmSwift
import JASON
import ReachabilitySwift

class OtherServicesView: UIView ,UITableViewDelegate{
    
    
    @IBOutlet weak var tbvListCombo: UITableView!
    
    var comboVariables : Variable<[OtherService]> = Variable([])
    var reachability : Reachability?
    var isConnectInternet = true
    
    static func createInView(view: UIView) -> OtherServicesView{
        let otherServicesView = NSBundle.mainBundle().loadNibNamed("OtherServicesView", owner: self, options: nil) [0] as! OtherServicesView
        view.layoutIfNeeded()
        otherServicesView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        
        view.addSubview(otherServicesView)
        otherServicesView.alpha = 0
        UIView .animateWithDuration(0.2) {
            otherServicesView.alpha = 1
        }
        otherServicesView.setupContent()
        return otherServicesView
    }
    
    
    func setupContent(){
        do {
            reachability = try! Reachability.reachabilityForInternetConnection()
        }
        reachability!.whenReachable = {
            reachability in
            self.isConnectInternet = true
            dispatch_async(dispatch_get_main_queue()) {
               self.comboVariables.value = []
                self.parseJsonOtherServices {}
            }
        }
        reachability!.whenUnreachable = {
            reachability in
            self.isConnectInternet = false
            dispatch_async(dispatch_get_main_queue()) {
               self.comboVariables.value = []
               self.comboVariables.value = OtherService.getAllSalon()
            }
        }
        self.setupTableView()
        try! reachability?.startNotifier()
    }
    
    func setupTableView(){
        self.tbvListCombo.rowHeight = self.tbvListCombo.frame.width*495/881//self.tbvListCombo.frame.height/4;
        self.tbvListCombo.registerNib(UINib.init(nibName: "OtherServicesCell", bundle: nil), forCellReuseIdentifier: "OtherServicesCell")
        self.tbvListCombo.setEditing(false, animated: false)
        dispatch_async(dispatch_get_main_queue()) {
            _ = self.comboVariables.asObservable().bindTo(self.tbvListCombo.rx_itemsWithCellIdentifier("OtherServicesCell", cellType: OtherServicesCell.self)){
                row, data, cell in
                if(data.listImages.count > 0){
                    cell.btnPrice.text = data.listImages[0].title
//                    LazyImage.showForImageView(cell.imvBackground, url: data.listImages[0].url,defaultImage: IMG_DEFAULT)
                    self.showAndDownLoadImage(cell.imvBackground, url: data.listImages[0].url, imageName: data.listImages[0].url)
                }
            }
            
            _ = self.tbvListCombo.rx_itemSelected.subscribeNext{
                indexPath in
                self.tbvListCombo.deselectRowAtIndexPath(indexPath, animated: false)
            }
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    func parseJsonOtherServices(complete:()->()){
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let parameter = ["Id": 2]
            Alamofire.request(.POST, OTHER_SERVICES_API,parameters: parameter,encoding: .JSON).responseJASON { response in
                if let json = response.result.value {
                    let otherServices = json["d"].map(OtherServiceNetwork.init)
                    for otherService in otherServices {
                        
                        let listImages : List<ImageObject> = List<ImageObject>()
                        for image in otherService.images {
                            let newSalonImage:ImageObject = ImageObject.create(image.url, thumb: image.thumb, title: image.title, img_description: image.img_description)
                            listImages.append(newSalonImage)
                        }
                        
                        let listVideo : List<VideoObject> = List<VideoObject>()
                        for video in otherService.videos {
                            let newVideo : VideoObject = VideoObject.create(video.url, thumb: video.thumb, title: video.thumb, img_description: video.img_description)
                            listVideo.append(newVideo)
                        }
                        
                        let newOtherService : OtherService = OtherService.create(otherService.ID, name: otherService.name, listImages: listImages, listVideos: listVideo)
                        self.comboVariables.value.append(newOtherService)
                    }
                    complete()
                }
            }
        }
    }
    
}

extension OtherServicesView {
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
    
    func showAndDownLoadImage(imageView : UIImageView, url: String, imageName: String) {
        if self.isConnectInternet {
            LazyImage.showForImageView(imageView, url: url, defaultImage: IMG_DEFAULT, completion: {
                let newName = imageName.stringByReplacingOccurrencesOfString("/", withString: "")
                if let dataa = UIImageJPEGRepresentation(imageView.image!, 0.8) {
                    let filename = self.getDocumentsDirectory().stringByAppendingPathComponent(newName)
                    dataa.writeToFile(filename, atomically: true)
                    print(filename)
                }
            })
        }
        else {
            imageView.image = UIImage(contentsOfFile: self.getImagePathFromDisk(imageName))
            print(imageName)
        }
    }
    
}
