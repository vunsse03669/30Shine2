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

class CustomerHistoryView: UIView, UITableViewDelegate {

    @IBOutlet weak var tbvHistory: UITableView!
    var historyVar : Variable<[CustomerHistory]> = Variable([])
    override func awakeFromNib() {
        super.awakeFromNib()
        tbvHistory.delegate = self
        self.parseJSON { 
            () in
            self.configTableView()
            let frame = CGRectMake(50, 20, 5, CGFloat(self.historyVar.value.count)*120 - 50)
            let lineView = UIView(frame: frame)
            lineView.backgroundColor = UIColor(netHex: 0xD8D9DB)
            self.tbvHistory.addSubview(lineView)
            lineView.layer.zPosition = -1000
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
            cell.lblDay.text = "\(self.format(self.getDay(data.createTime)))"
            cell.lblHour.text = "\(self.getHour(data.createTime))"
            cell.lblRate.text = "\(data.rating)"
            cell.lblStylist.text = "\(data.stylistName)"
            cell.lblService.text = "\(data.service)"
        }
        
        _ = self.tbvHistory.rx_itemSelected.subscribeNext {
            indexPath in
            self.tbvHistory.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    func getHour(hour : String) -> String {
        var str = ""
        for c in hour.characters {
            str.append(c)
            if c == " " {
                break
            }
        }
        let id = hour.stringByReplacingOccurrencesOfString(str, withString: "")
        return id
    }
    
    func getDay(day : String) -> String {
        var str = ""
        for c in day.characters {
            str.append(c)
            if c == " " {
                break
            }
        }
        
        return str
    }
    
    func format(str : String) -> String {
        var day = ""
        var month = ""
        var year = ""
        var count = 0
        
        print("ccc \(str)")
        for c in str.characters {
            if c == " " {
                break
            }
            if c == "-" {
                count += 1
            }
            
            switch count {
            case 0:
                year.append(c)
            case 1:
                month.append(c)
            case 2:
                day.append(c)
            default:
                print("xxx")
            }
            
            
            
            
        }
        day = day.stringByReplacingOccurrencesOfString("-", withString: "")
        month = month.stringByReplacingOccurrencesOfString("-", withString: "")
        year = year.stringByReplacingOccurrencesOfString("-", withString: "")
        return "\(day)-\(month)-\(year)"
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
                        }
                    }
                   complete()
                }
            }
        }
    }
    
    //MARK: table delegate
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
}
