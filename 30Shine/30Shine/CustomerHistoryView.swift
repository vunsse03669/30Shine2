//
//  CustomerHistoryView.swift
//  30Shine
//
//  Created by Mr.Vu on 7/23/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire

class CustomerHistoryView: UIView {

    @IBOutlet weak var tbvHistory: UITableView!
    var historyVar : Variable<[CustomerHistory]> = Variable([])
    override func awakeFromNib() {
        super.awakeFromNib()
        self.parseJSON { 
            () in
            self.configTableView()
//            let frame = CGRectMake(50, 20, 5, self.bounds.height)
//            let lineView = UIView(frame: frame)
//            lineView.backgroundColor = UIColor(netHex: 0xDBDDDE)
//            self.addSubview(lineView)

        }
    }
    
    static func createView(view : UIView) -> CustomerHistoryView! {
        let customerView = NSBundle.mainBundle().loadNibNamed("CustomerHistoryView", owner: self, options: nil)[0] as! CustomerHistoryView
        view.layoutIfNeeded()
        customerView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        
        view.addSubview(customerView)
        customerView.alpha = 0
        UIView .animateWithDuration(0.2) {
            customerView.alpha = 1
        }
        return customerView
    }
    
    //MARK: tableview
    func configTableView() {
        self.tbvHistory.registerNib(UINib.init(nibName: "CustomerHistoryCell", bundle: nil), forCellReuseIdentifier: "CustomerHistoryCell")
        self.tbvHistory.rowHeight = 120
        self.tbvHistory.separatorStyle = UITableViewCellSeparatorStyle.None
        
        _ = self.historyVar.asObservable().bindTo(self.tbvHistory.rx_itemsWithCellIdentifier("CustomerHistoryCell", cellType: CustomerHistoryCell.self)) {
            row,data,cell in
            cell.lblDay.text = "\(data.createTime)"
            cell.lblRate.text = "\(data.rating)"
            cell.lblStylist.text = "\(data.stylistName)"
            cell.lblService.text = "\(data.service)"
            
        }
        
        _ = self.tbvHistory.rx_itemSelected.subscribeNext {
            indexPath in
            self.tbvHistory.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    //MARK: data
    func parseJSON(complete: ()->()) {
        let parameter = ["Id" : 1000]
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            Alamofire.request(.POST,HISTORY_API,parameters: parameter, encoding: .JSON).responseJASON {
                response in
                if let json = response.result.value {
                    let histories = json["d"].map(HistoryNetwork.init)
                    for history in histories {
                        if CustomerHistory.getCustomerHistoryByTime(history.billCreatedTime) == nil {
                            let h = CustomerHistory.create(history.billCreatedTime, stylist: history.stylistName, skinner: history.skinnerName, rating: history.rating, service: history.services[0].name)
                            // services can fix
                            self.historyVar.value.append(h)
                        }
                        else {
                            self.historyVar.value.append(CustomerHistory.getCustomerHistoryByTime(history.billCreatedTime))
                                print(CustomerHistory.getCustomerHistoryByTime(history.billCreatedTime).service)
                        }
                    }
                   complete()
                }
            }
        }
    }
    
}
