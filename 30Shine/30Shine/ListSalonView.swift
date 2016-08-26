//
//  ListSalonView.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire
import JASON
import RealmSwift
import ReachabilitySwift
import SVProgressHUD

class ListSalonView: UIView, UITableViewDelegate {
    
    var reachability : Reachability?
    var isConnectInternet = true
    var navigation : UINavigationController!
    @IBOutlet weak var tbvListSalon: UITableView!
    var salonVariable  : Variable<[Salon]> = Variable([])
    override func awakeFromNib() {
        initData()
    }
    
    static func createInView(view: UIView) -> ListSalonView{
        let listSalonView = NSBundle.mainBundle().loadNibNamed("ListSalonView", owner: self, options: nil) [0] as! ListSalonView
        view.layoutIfNeeded()
        listSalonView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        
        view.addSubview(listSalonView)
        listSalonView.alpha = 0
        UIView .animateWithDuration(0.2) {
            listSalonView.alpha = 1
        }
        return listSalonView
    }
    
    func initData(){
        
        do {
            reachability = try! Reachability.reachabilityForInternetConnection()
        }
        reachability!.whenReachable = {
            reachability in
            self.isConnectInternet = true
            dispatch_async(dispatch_get_main_queue()) {
                
                //activity indicator
                SVProgressHUD.showWithStatus("Đang tải dữ liệu")
                
                self.salonVariable.value = []
                self.parseJsonSalonSystem({ 
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
                self.salonVariable.value = []
                self.salonVariable.value = Salon.getAllSalon()
                print(self.salonVariable.value)
            }
        }
        self.configCollectionView()
        try! reachability?.startNotifier()
        
    }
    //MARK: TableView DataSource
    func configCollectionView() {
        tbvListSalon.registerNib(UINib.init(nibName: "SalonTableCell", bundle: nil), forCellReuseIdentifier: "SalonTableCell")
        tbvListSalon.rowHeight = 120
        
        tbvListSalon.tableFooterView = UIView()
        
        dispatch_async(dispatch_get_main_queue()) {
            _ =           self.salonVariable.asObservable().bindTo(self.tbvListSalon.rx_itemsWithCellIdentifier("SalonTableCell", cellType: SalonTableCell.self)){
                row,data,cell in
                let title = "30SHINE"
                cell.lblAdress.text = String(format: "%@ %@", title, data.name)
                cell.phone = data.phone;
                cell.salonId = data.ID
                //cell.lblManager.text = data.managerName
                //cell.lblHotLine.text = data.phone
                //cell.lblFacebookLink.text = data.fanpage
                //print("count iamge \(data.listImages.count)")
                //if(data.listImages.count>0){
                    if self.isConnectInternet {
                        self.showAndDownLoadImage(cell.imvSalon, url: data.listImages[0].url, imageName: data.listImages[0].url)
                    }
                    else {
                        let name = data.listImages[0].url.stringByReplacingOccurrencesOfString("/", withString: "")
                        cell.imvSalon.image = UIImage(contentsOfFile: self.getImagePathFromDisk("\(name)"))
                    }
                    //LazyImage.showForImageView(cell.imvSalon, url: data.listImages[0].url)
                //}
            }
        }
        _ = self.tbvListSalon.rx_itemSelected.subscribeNext {
            indexPath in
            self.tbvListSalon.deselectRowAtIndexPath(indexPath, animated: false)
            let salon = self.salonVariable.value[indexPath.row]
            self.showDetail(salon)
        }
    }
    //MARK: TableView Delegate
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    func showDetail(salon:Salon){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewControllerWithIdentifier("DetailSalonViewController") as? DetailSalonViewController
        self.navigation.push(detailVC!, animated: true)
        detailVC!.currentSalon = salon
        
    }
    
    func disappearDetail(){
        UIView .animateWithDuration(0.5, animations: {
            //  self.detailSalonView.alpha = 0
        }) { (completion) in
            //self.detailSalonView.removeFromSuperview()
        }
    }
    
    func parseJsonSalonSystem(complete:()->()){
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let parameter = ["Id": 2]
            Alamofire.request(.POST, SALON_LIST_API,parameters: parameter,encoding: .JSON).responseJASON { response in
                if let json = response.result.value {
                    let salons = json["d"].map(SalonNetwork.init)
                    for salon in salons {
                        if(salon.ID==6){ return}
                        print(salon.ID)
                        let listImages : List<ImageObject> = List<ImageObject>()
                        for salonIN in salon.images {
                            let newSalonImage:ImageObject = ImageObject.create(salonIN.url, thumb: salonIN.thumb, title: salonIN.title, img_description: salonIN.img_description)
                            listImages.append(newSalonImage)
                        }
                        if Salon.getSalonByID(salon.ID) == nil{
                        let newSalon : Salon = Salon.create(salon.ID, name: salon.name, phone: salon.phone, managerName: salon.managerName, fanpage: salon.fanpage, listImages: listImages)
                        self.salonVariable.value.append(newSalon)
                        }
                        else{
                            self.salonVariable.value.append(Salon.getSalonByID(salon.ID))
                        }
                    }
                    complete()
                }
            }
        }
    }
}

extension ListSalonView {
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
        LazyImage.showForImageView(imageView, url: url, completion: {
            let newName = imageName.stringByReplacingOccurrencesOfString("/", withString: "")
            if let dataa = UIImageJPEGRepresentation(imageView.image!, 0.8) {
                let filename = self.getDocumentsDirectory().stringByAppendingPathComponent(newName)
                dataa.writeToFile(filename, atomically: true)
                print(filename)
            }
        })
        
        

    }
    
}

