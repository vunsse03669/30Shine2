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
        self.tbvMessage.delegate = self
        self.configTableView()
//        self.sortedTableView { 
//            self.configTableView()
//        }
    }
    
    //MARK: UI
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationController?.navigationBar.translucent = false
        
        //remove separator for tableview
        self.tbvMessage.separatorStyle = .None
        
        //back image
        var backImage = UIImage(named: "img-back")
        backImage = backImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleBackButton))
    }
    
    func handleBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
//    //MARK: Config Tableview
//    func sortedTableView(completion : ()->()) {
//        self.messagesVar.value.sortInPlace {
//            return ($0).message?.time > ($1).message?.time
//        }
//        completion()
//    }
    
    func configTableView() {
        
        _ = self.messagesVar.asObservable().bindTo(self.tbvMessage.rx_itemsWithCellIdentifier("MessageCell", cellType: MessageCell.self)) {
            row,data,cell in
            cell.lblTitle.text = data.message?.title
            cell.lblTime.text = data.message?.time
            
            if data.message?.icon == "ic_info_status_bar" {
                cell.imvIcon.image = UIImage(named: "img-info")
            }
            else if data.message?.icon == "ic_read_message_status_bar" {
                cell.imvIcon.image = UIImage(named: "img-messageNote")
            }
            else if data.message?.icon == "img-calendar" {
                cell.imvIcon.image = UIImage(named: "img-calendar")
            }
            
            if !(data.message?.isRead)! {
                cell.lblNote.hidden = false
            }
            else {
                cell.lblNote.hidden = true
            }
        }
        
        _ = self.tbvMessage.rx_itemSelected.subscribeNext {
            indexPath in
            var body = ""
            let icon = self.messagesVar.value[indexPath.row].message!.icon
            var iconPath = ""
            if icon == "ic_info_status_bar" {
                iconPath = "img-info"
            }
            else if icon == "ic_read_message_status_bar" {
                iconPath = "img-messageNote"
            }
            else if icon == "img-calendar" {
                iconPath = "img-calendar"
            }
            
            var imagePath = ""
            let message = self.messagesVar.value[indexPath.row].message!
            imagePath = message.image
            
            if ((self.messagesVar.value[indexPath.row].message?.body.containsString("<#customername#")) != nil) {
                let name = Login.getLogin().fullName
                body = (self.messagesVar.value[indexPath.row].message?.body)!
                body = body.stringByReplacingOccurrencesOfString("<#customername", withString: name).stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString("#", withString: "")
            }
            
            self.tbvMessage.deselectRowAtIndexPath(indexPath, animated: false)
            let title = self.messagesVar.value[indexPath.row].message!.title
            let time = self.messagesVar.value[indexPath.row].message!.time
            
            let msgView = MessageAlertView.createView(self.view, title: title, time: time, iconPath: iconPath,imagePath: imagePath, content: body)
            msgView.delegate = self
            self.view.backgroundColor = UIColor(netHex: 0x9E9E9E)
            ContentMessage.hadRead(self.messagesVar.value[indexPath.row].message!)
            self.tbvMessage.userInteractionEnabled = false
        }
    }
    
    //MARK: Data
    func initData() {
        let userId = Login.getLogin().id
        self.messagesVar.value = Message.getMessageByUserId(userId)
    }

}

extension MessageController : MessageAlertProtocol, UITableViewDelegate {
    func changeColor() {
        self.view.backgroundColor = UIColor.whiteColor()
        self.tbvMessage.userInteractionEnabled = true
        self.tbvMessage.reloadData()
    }
    
     func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if self.tbvMessage.editing {return .Delete}
        return .None
    }
}
