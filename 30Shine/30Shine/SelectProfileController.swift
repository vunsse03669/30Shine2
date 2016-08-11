//
//  SelectProfileController.swift
//  30Shine
//
//  Created by Apple on 8/11/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SelectProfileController: UIViewController {

    @IBOutlet weak var tbvItem: UITableView!
    var itemVariable : Variable<[ProfileItem]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.initData()
        self.configTableView()
    }
    
    func handleBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: profileImage, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
    }
    
    //MARK: Config TableView
    func configTableView() {
        _ = self.itemVariable.asObservable().bindTo(self.tbvItem.rx_itemsWithCellIdentifier("ProfileItemCell", cellType: ProfileItemCell.self)) { row,data,cell in
            cell.imvImage.image = UIImage(named: data.imagePath)
            cell.lblTitle.text = data.title
        }
            
        _ = self.tbvItem.rx_itemSelected.subscribeNext { indexPath in
            self.tbvItem.deselectRowAtIndexPath(indexPath, animated: false)
            let selectedCell : ProfileItemCell = self.tbvItem.cellForRowAtIndexPath(indexPath) as! ProfileItemCell
            
            selectedCell.bounceAction({
                var vc : UIViewController!
                switch indexPath.row {
                case 0 :
                    vc = self.storyboard?.instantiateViewControllerWithIdentifier("CustomerInfoController") as? CustomerInfoController
                case 1 :
                    print("Selected Invalid !!!")
                    
                case 2:
                    vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController
                default:
                    print("Selected Invalid !!!")
                }
                if vc != nil {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })

        }
    }
    
    //MARK: Data
    func initData() {
        self.itemVariable.value.append(ProfileItem(title: "Thông tin khách hàng", imagePath: "img-customer"))
        self.itemVariable.value.append(ProfileItem(title: "Tin nhắn", imagePath: "img-message"))
        self.itemVariable.value.append(ProfileItem(title: "Lịch sử khách hàng", imagePath: "img-history"))
    }
}
