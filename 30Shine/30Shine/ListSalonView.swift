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

class ListSalonView: UIView, UITableViewDelegate {
    
    @IBOutlet weak var tbvListSalon: UITableView!
    
    var salonVariable  : Variable<[Salon]> = Variable([])
    var detailSalonView : DetailSalonView!
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
        parseJsonSalonSystem {
            () in
            self.configCollectionView()
        }
        
    }
    //MARK: TableView DataSource
    func configCollectionView() {
        tbvListSalon.registerNib(UINib.init(nibName: "SalonTableCell", bundle: nil), forCellReuseIdentifier: "SalonTableCell")
        tbvListSalon.rowHeight = 120
        dispatch_async(dispatch_get_main_queue()) {
            _ =           self.salonVariable.asObservable().bindTo(self.tbvListSalon.rx_itemsWithCellIdentifier("SalonTableCell", cellType: SalonTableCell.self)){
                row,data,cell in
                cell.lblAdress.text = data.name
                cell.lblManager.text = data.managerName
                cell.lblHotLine.text = data.phone
                cell.lblFacebookLink.text = data.fanpage
                print("count iamge \(data.listImages.count)")
                if(data.listImages.count>0){
                    LazyImage.showForImageView(cell.imvSalon, url: data.listImages[0].url)
                }
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
        //self.detailSalonView = DetailSalonView.createInView(self, contentSalon: salon)
    }
    
    func disappearDetail(){
        UIView .animateWithDuration(0.5, animations: {
            self.detailSalonView.alpha = 0
        }) { (completion) in
            self.detailSalonView.removeFromSuperview()
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
                        let newSalon : Salon = Salon.create(salon.ID, name: salon.name, phone: salon.phone, managerName: salon.managerName, fanpage: salon.fanpage, listImages: listImages)
                        self.salonVariable.value.append(newSalon)
                    }
                    complete()
                }
            }
        }
    }
}
