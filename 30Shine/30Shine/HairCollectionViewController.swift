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

class HairCollectionViewController: UIViewController {

    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var tbvHairType: UITableView!
    
    var hairTypeVariable : Variable<[HairType]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.initData()
        //back to home
        _ = btnHome.rx_tap
            .subscribeNext {
                self.navigationController?.pop()
        }
        //Click btnProfile
        _ = btnProfile.rx_tap.subscribeNext {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
            self.navigationController?.push(vc, animated: true)
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
            LazyImage.showForImageView(cell.imvImage, url: data.images[0].imageUrl)
        }
        
        _ = self.tbvHairType.rx_itemSelected.subscribeNext {
            indexPath in
            self.tbvHairType.deselectRowAtIndexPath(indexPath, animated: false)
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DetailHairViewController") as! DetailHairViewController
            vc.menuVar.value = self.hairTypeVariable.value[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: Dump data
    func initData() {
        self.parseJSON { 
            () in
            self.configTableView()
        }
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

}
