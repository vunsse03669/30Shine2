//
//  AdviseMenuController.swift
//  30Shine
//
//  Created by Apple on 8/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class AdviseMenuController: UIViewController {
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var tbvMenu: UITableView!
    
    
    var adviseMenu : Variable<[AdviseMenu]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.initData()
        self.configTableView()
    }
    
    //MARK: Config UI
    func handleBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func handleProfile() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SelectProfileController") as! SelectProfileController
        self.navigationController?.push(vc, animated: true)
    }
    
    
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationController?.navigationBar.translucent = false
        //back image
        var backImage = UIImage(named: "img-back")
        backImage = backImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleBackButton))
        //profile image
        var profileImage = UIImage(named: "img-people")
        profileImage = profileImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: profileImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleProfile))
        
        //Consultant date
        if AdviseHair.getAdviseHair() != nil {
            let consultantDate = AdviseHair.getAdviseHair().dateConsultant
            self.lblDate.text = "Lần tư vấn gần nhất: \(consultantDate)"
        }
    }
    
    //MARK: Config table view 
    func configTableView() {
        //binding data
        _ = self.adviseMenu.asObservable().bindTo(self.tbvMenu.rx_itemsWithCellIdentifier("AdviseMenuCell", cellType: AdviseMenuCell.self)) {
            row,data,cell in
                cell.lblTitle.text = data.title
                cell.lblDescreption.text = data.descreption
                cell.imvAvatar.image = UIImage(named: "\(data.imagePath)")
        }
        
        //click on each item
        _  = self.tbvMenu.rx_itemSelected.subscribeNext {
            indexPath in
            
            self.tbvMenu.deselectRowAtIndexPath(indexPath, animated: false)
            var vc : UIViewController!
            
            switch indexPath.row {
            case 0:
                vc = self.storyboard?.instantiateViewControllerWithIdentifier("AdviseHairController") as! AdviseHairController
            case 1 :
                vc = self.storyboard?.instantiateViewControllerWithIdentifier("AdviseSkinController") as! AdviseSkinController
            default:
                print("invalid!")
            }
            
            if vc != nil {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //MARK: Init data
    func initData() {
        self.adviseMenu.value.append(AdviseMenu(title: "Tóc và da đầu",
            descreption: "Xem phân tích chất tóc và da đâu của bạn hơn để chăm sóc cho đúng cách", imagePath: "shineCombo"))
        self.adviseMenu.value.append(AdviseMenu(title: "Da và cơ thể",
            descreption: "Hiểu loại da của bạn để lựa chọn sản phẩm chăm sóc tóc phù hợp", imagePath: "shineCombo"))
    }

}
