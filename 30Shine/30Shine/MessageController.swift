//
//  MessageController.swift
//  30Shine
//
//  Created by Apple on 8/28/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MessageController: UIViewController {
    @IBOutlet weak var tbvMessage: UITableView!
    
    var messagesVar : Variable<[Message]> = Variable([])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.initData()
        self.configTableView()
    }
    
    //MARK: UI
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
    }
    
    func handleBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: Config Tableview
    func configTableView() {
        _ = self.messagesVar.asObservable().bindTo(self.tbvMessage.rx_itemsWithCellIdentifier("MessageCell", cellType: MessageCell.self)) {
            row,data,cell in
            cell.lblTitle.text = data.message?.title
            cell.imvIcon.image = UIImage(named: "img-customer")
        }
    }
    
    //MARK: Data
    func initData() {
        let userId = Login.getLogin().id
        self.messagesVar.value = Message.getMessageByUserId(userId)
    }


}
