//
//  Advise.swift
//  30Shine
//
//  Created by Đỗ Ngọc Trình on 8/23/16.
//  Copyright © 2016 vu. All rights reserved.
//
import UIKit
import RxCocoa
import RxSwift
import Alamofire
import RealmSwift
import ReachabilitySwift

class AdviseSkinView: UIView {
    
    @IBOutlet weak var tbvProduct: UITableView!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    var advise : Variable<[AdviseHair]> = Variable([])
    var product : Variable<[Product]> = Variable([])
    var reachability : Reachability?
    var isConnectInternet = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configData()
    }
    
    static func createView(parentView : UIView) {
        let adviseView = NSBundle.mainBundle().loadNibNamed("AdviseSkinView", owner: self, options: nil) [0] as! AdviseSkinView
        let frame = CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.width)
        adviseView.frame = frame
        parentView.addSubview(adviseView)
    }
    
    func addImage() {
        //remove all items in view
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        // add image
        self.layoutIfNeeded()
        let frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .ScaleAspectFill
        imageView.image = UIImage(named: "img-modelHair")
        self.addSubview(imageView)
        self.bringSubviewToFront(imageView)
    }
    
    //MARK: config tableview
    func configTableView() {
        self.tbvProduct.registerNib(UINib.init(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        self.tbvProduct.rowHeight = 120
        
        //binding data
        _ = self.product.asObservable().bindTo(self.tbvProduct.rx_itemsWithCellIdentifier("ProductCell", cellType: ProductCell.self)) {
            row,data,cell in
            cell.lblTitle.text = data.productName
            cell.lblPrice.text = "\(data.price)"
            //            LazyImage.showForImageView(cell.imvAvatar, url: data.thumb, completion: {
            //
            //            })
            self.showAndDownloadImage(cell.imvAvatar, url: data.thumb, imageName: data.thumb)
        }
    }
    
    //MARK: config data
    func configData() {
        do {
            reachability = try! Reachability.reachabilityForInternetConnection()
        }
        reachability!.whenReachable = {
            reachability in
            self.isConnectInternet = true
            dispatch_async(dispatch_get_main_queue()) {
                self.advise.value = []
                let cId = Login.getLogin().id
                self.parseJson(cId) {
                    // have data
                    if self.advise.value[0].dateConsultant != "" {
                        self.bindingData()
                    }
                        // not have data
                    else {
                        self.addImage()
                    }
                }
            }
        }
        reachability!.whenUnreachable = {
            reachability in
            self.isConnectInternet = false
            dispatch_async(dispatch_get_main_queue()) {
                self.advise.value = []
                self.product.value = []
                if AdviseHair.getAdviseHair() != nil {
                    self.advise.value.append(AdviseHair.getAdviseHair())
                    // have data
                    if self.advise.value[0].dateConsultant != "" {
                        self.bindingData()
                    }
                        // not have data
                    else {
                        self.addImage()
                    }
                }
                if Product.getAllProduct().count != 0 {
                    self.product.value = Product.getAllProduct()
                }
            }
        }
        
        self.configTableView()
        
        try! reachability?.startNotifier()
    }
    
    func bindingData() {
        self.lblNote.text = self.advise.value[0].descriptionn
    }
    
    func checkData() {
        // have data
        if self.advise.value[0].dateConsultant != "" {
            self.bindingData()
        }
            // not have data
        else {
            self.addImage()
        }
    }
    
    func parseJson(customerId : Int, completion : () -> ()) {
        let parameter = ["CustomerId" : customerId]
        let dApi = "http://api.30shine.com/consultant/skin"
        
        Alamofire.request(.POST, dApi, parameters: parameter, encoding: .JSON).responseJASON {
            response in
            if let json = response.result.value {
                let advise = AdviseHairNetwork.init(json["d"])
                let products = List<Product>()
                
                for product in advise.products {
                    if Product.getProductById(product.id) == nil {
                        let p = Product.create(product.id, productName: product.productName, price: product.price, thumb: product.thumb)
                        products.append(p)
                        self.product.value.append(p)
                    }
                    else {
                        let p = Product.getProductById(product.id)
                        products.append(p)
                        self.product.value.append(p)
                    }
                }
                
                if AdviseHair.getAdviseHairByDate(advise.dateConsultant) == nil {
                    let adviseHair = AdviseHair.create(advise.description, date: advise.dateConsultant, product: products)
                    self.advise.value.append(adviseHair)
                }
                else {
                    let adviseHair = AdviseHair.getAdviseHairByDate(advise.dateConsultant)
                    self.advise.value.append(adviseHair)
                }
                
                completion()
            }
        }
    }
    
    //MARK: Helper
    func alert(title : String, msg : String) {
        let alert = UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: "Xác nhận")
        alert.show()
    }
}

extension AdviseSkinView {
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