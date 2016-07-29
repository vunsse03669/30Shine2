//
//  BookingViewController.swift
//  30Shine
//
//  Created by Mr.Vu on 7/26/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

class BookingViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var clvBooking: UICollectionView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var vContainer: UIView!
    
    var dropSalon : UIDropDown!
    var dropTime : UIDropDownTime!
    var dropStylist : UIDropDownStylist!
    
    var dataVar : Variable<[Booking]> = Variable([])
    var stylistVar : Variable<[Stylist]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.configCollectionView()
        self.parseSchedule(3, workDate: "29-07-2016", stylistId: 0) {
            () in
        }

        
        _ = btnHome.rx_tap
            .subscribeNext {
                //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                self.navigationController?.pop()
        }
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
        self.scrollView.bringSubviewToFront(self.vContainer)
        self.clvBooking.layer.zPosition = -1000
        
        self.txtPhone.layer.cornerRadius = 5.0
        self.txtPhone.layer.borderColor = UIColor.blackColor().CGColor
        self.txtPhone.layer.borderWidth = 1.0
        self.txtPhone.clipsToBounds = true
        self.txtName.layer.cornerRadius = 5.0
        self.txtName.layer.borderWidth = 1.0
        self.txtName.layer.borderColor = UIColor.blackColor().CGColor
        self.txtName.clipsToBounds = true
        
        self.txtName.layoutIfNeeded()
        self.vContainer.layoutIfNeeded()
        self.txtPhone.layoutIfNeeded()
        self.view.layoutIfNeeded()
        dropTime = UIDropDownTime(frame: CGRect(x: 0, y: 0, width: self.txtName.frame.size.width, height: 30))
        dropSalon = UIDropDown(frame: CGRect(x: 0, y: 0, width: self.txtName.frame.size.width, height: 30))
        dropStylist = UIDropDownStylist(frame: CGRect(x: 0, y: 0, width: self.txtName.frame.size.width, height: 30))
        
        dropSalon.center.x = self.txtPhone.center.x
        dropSalon.center.y = self.vContainer.center.y
        
        dropTime.center.x = dropSalon.center.x
        dropTime.center.y = dropSalon.center.y + 50
        
        dropStylist.center.x = dropTime.center.x
        dropStylist.center.y = dropTime.center.y + 50
        
        
        dropSalon.options = [ "2", "3", "4", "5"]
        dropTime.options = ["Hôm nay \(self.format(self.getDate(self.getTime(0))))",
                            "Ngày mai \(self.format(self.getDate(self.getTime(1))))",
                            "Ngày kia \(self.format(self.getDate(self.getTime(2))))"]
        
        self.scrollView.addSubview(dropSalon)
        self.scrollView.addSubview(dropTime)
        self.scrollView.addSubview(dropStylist)
        
        dropStylist.delegate = self
        dropSalon.delegate = self
        dropTime.delegate = self
        
        dropTime.setSelectedIndex(0)
        dropSalon.setSelectedIndex(0)
        
        dropTime.hideOptionsWhenSelect = true
        dropSalon.hideOptionsWhenSelect = true
        dropStylist.hideOptionsWhenSelect = true
        
        self.configCollectionViewLayout()

    }
    
    //MARK: CollectionView
    func configCollectionView() {
        _ = self.dataVar.asObservable().bindTo(self.clvBooking.rx_itemsWithCellIdentifier("BookingCell", cellType: BookingCell.self)) {
            row,data,cell in
            cell.lblTime.text = "\(data.hour)"
            
            if self.checkDate(29, month: 7, year: 2016, hour: self.getHour(data.hour), minute: self.getMinute(data.hour)) {
                cell.backgroundColor = UIColor.greenColor()
                cell.lblTime.textColor = UIColor.whiteColor()
                cell.lblStatus.textColor = UIColor.whiteColor()
                cell.lblStatus.text = "Còn chỗ"
            }
            else if data.currentSlot == data.slot {
                cell.backgroundColor = UIColor.redColor()
                cell.lblTime.textColor = UIColor.whiteColor()
                cell.lblStatus.textColor = UIColor.whiteColor()
                cell.lblStatus.text = "Hết chỗ"
            }
            else {
                cell.backgroundColor = UIColor.grayColor()
                cell.lblStatus.text = "Nghỉ"
            }
            
            cell.layer.cornerRadius = 5.0
            cell.clipsToBounds = true
        }
    }
    
    func configCollectionViewLayout() {
        self.vContainer.layoutIfNeeded()
        self.clvBooking.layoutIfNeeded()
        let layout : UICollectionViewFlowLayout! = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let width = self.vContainer.bounds.width/4 - 12
        let height = 0.8*width
        layout.itemSize = CGSizeMake(width, height)
        self.clvBooking.setCollectionViewLayout(layout, animated: true)
    }


}

extension BookingViewController {
    func getTime(time : Double) -> String {
        let today = NSDate()
        let date = today.dateByAddingTimeInterval((1 + time)*24 * 60 * 60)
       
        return String(date)
    }
    
    func getDate(day : String) -> String {
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
                print("")
            }
            
        }
        day = day.stringByReplacingOccurrencesOfString("-", withString: "")
        month = month.stringByReplacingOccurrencesOfString("-", withString: "")
        year = year.stringByReplacingOccurrencesOfString("-", withString: "")
        return "\(day)-\(month)-\(year)"
    }
    
    func getHour(time : String) -> Int! {
        var str = ""
        for c in time.characters {
            if c == "h" {
                break
            }
            str.append(c)
        }
        return Int(str)
    }
    
    func getMinute(time : String) -> Int! {
        var str = ""
        var status = false
        for c in time.characters {
            if c == "h" {
                status = true
            }
            if status {
                str.append(c)
            }
        }
        return Int(str.stringByReplacingOccurrencesOfString("h", withString: ""))
    }
    
    func checkTime(hour : Int, minute : Int) -> Bool {
        let h = NSCalendar.currentCalendar().component(NSCalendarUnit.Hour, fromDate: NSDate())
        let m = NSCalendar.currentCalendar().component(NSCalendarUnit.Minute, fromDate: NSDate())
        print(h)
        print(m)
        if hour > h + 1 || (hour == h + 1 && 60 - m + minute >= 30) {
            return true
        }
        else if h == hour {
            if minute - m >= 30 {
                return true
            }
        }
        return false
    }
    
    func checkDate(day : Int, month : Int, year : Int, hour : Int, minute : Int) -> Bool {
        let d = NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: NSDate())
        let m = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: NSDate())
        let y = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: NSDate())
        
        if year > y {
            return true
        }
        else if year == y {
            if month > m {
                return true
            }
            else if month == m {
                if day > d {
                    return true
                }
                else if day == d {
                    if self.checkTime(hour, minute: minute) {
                        return true
                    }
                }
            }
            
        }
        
        return false
    }



}

extension BookingViewController : UIDropDownDelegate {
    func dropDown(dropDown: UIDropDown, didSelectOption option: String, atIndex index: Int) {
        self.parseStylist(Int(option)!) {
            () in
            self.dropStylist.options = []
            for stylist in self.stylistVar.value {
                self.dropStylist.options.append(stylist.fullName)
            }
            
        }

    }
}

extension BookingViewController : UIDropDownTimeDelegate {
    func dropDownTime(dropDown: UIDropDownTime, didSelectOption option: String, atIndex index: Int){
        
    }
}

extension BookingViewController : UIDropDownStylistDelegate {
    func dropDownStylist(dropDown: UIDropDownStylist, didSelectOption option: String, atIndex index: Int){
        
    }
}

extension BookingViewController {
    func parseSchedule(salonId : Int, workDate : String, stylistId : Int, compeletion : () ->()) {
        /*
         SalonId: 3,
         WorkDate: '27-07-2016'
         */
        let BOOKING_API = "http://api.30shine.com/booking/dsbookhour"
        let parameter = ["SalonId":salonId,"WorkDate":workDate,"Stylist":stylistId]
        self.dataVar.value = []
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            Alamofire.request(.POST, BOOKING_API, parameters: parameter as? [String : AnyObject], encoding: .JSON).responseJASON {
                response in
                if let json = response.result.value {
                    let bookings = json["d"].map(BookingNetwork.init)
                    for booking in bookings {
                        let data = Booking(id: booking.id, hour: booking.hour, status: "", slot: booking.slot, hourFrame: booking.hourFrame, salonId: booking.salonId, currentSlot: booking.currentSlot, stylistCurrentSlot: booking.stylistCurrentSlot)
                        self.dataVar.value.append(data)
                    }
                    compeletion()
                }
            }
        }
    }
    
    func parseStylist(staffId : Int,completion : ()->()) {
        let GET_STYLIST_API = "http://api.30shine.com/staff/stylist"
        let parameter = ["SalonId":staffId]
        self.stylistVar.value = []
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            Alamofire.request(.POST, GET_STYLIST_API, parameters: parameter, encoding: .JSON).responseJASON {
                response in
                if let json = response.result.value {
                    let stylists = json["d"].map(StylistNetwork.init)
                    for stylist in stylists {
                        let data = Stylist(id: stylist.id, fullName: stylist.fullName, salonId: stylist.salonId)
                        self.stylistVar.value.append(data)
                    }
                    completion()
                }
            }
        }
        
    }
}



