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
    var choseStylist = false
    var stylistId : [Int] = [0]
    var salonId : [Int] = [2,3,4,5]
    var salonList : [String] = ["346 Khâm Thiên",
                                "82 Trần Đại Nghĩa",
                                "235 Đội Cấn",
                                "702 Đường Láng"]
    var salontCount = 0
    var dateCount = 0
    var stylistCount = 0
    
    var bookingTimeId : Variable<Int> = Variable(0)
    var dataVar : Variable<[Booking]> = Variable([])
    var stylistVar : Variable<[Stylist]> = Variable([])
    var statusDate : Variable<Double> = Variable(0)
    var statusSalonId : Variable<Int> = Variable(0)
    var statusStylistIndex : Variable<Int> = Variable(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.configCollectionView()
        self.parseSchedule(salonId[0], workDate: self.toDate(0), stylistId: 0) {
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
        
        _ = btnSubmit.rx_tap.subscribeNext {
            print("Name : \(self.txtName.text)")
            print("Phone: \(self.txtPhone.text)")
            print("Salon id: \(self.statusSalonId.value)")
            print("Date : \(self.toDate(self.statusDate.value))")
            print("Stylist id : \(self.stylistId[self.statusStylistIndex.value])")
            print("HourId : \(self.bookingTimeId.value)")
            
            let name = self.txtName.text!
            let phone = self.txtPhone.text!
            let salonId = String(self.statusSalonId.value)
            let date = self.toDate(self.statusDate.value)
            let stylistId = String(self.stylistId[self.statusStylistIndex.value])
            let hourId = String(self.bookingTimeId.value)
            if name != "" && phone != "" && date != "" && hourId != "0" {
                print("booking")
                if self.choseStylist {
                    sNetworkSender.sendBooking(name, phone: phone, salonID: salonId, dateBook: date, StylistId: stylistId, hourId: hourId,completion: {
                        Bool in
                        if(Bool){
                            print("DONE")
                            let alert =  UIAlertView(title: "BOOKING DONE", message: "", delegate: nil, cancelButtonTitle: "Close")
                            alert.show()
                        }
                        else{
                            let alert =  UIAlertView(title: "BOOKING DONE", message: "", delegate: nil, cancelButtonTitle: "Close")
                            alert.show()
                            print("ERROR")
                        }
                        return Bool
                    })
                }
                else {
                    
                    sNetworkSender.sendBooking(name, phone: phone, salonID: salonId, dateBook: date, StylistId: "0", hourId: hourId,completion: {
                        Bool in
                        if(Bool){
                            print("DONE")
                            let alert =  UIAlertView(title: "BOOKING DONE", message: "", delegate: nil, cancelButtonTitle: "Close")
                            alert.show()
                        }
                        else{
                            let alert =  UIAlertView(title: "BOOKING DONE", message: "", delegate: nil, cancelButtonTitle: "Close")
                            alert.show()
                            print("ERROR")
                        }
                        return Bool
                    })
                    
                    
                }
                
            }
            else {
                let alert = UIAlertView(title: "", message: "Booking failed. Please fill all field require", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
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
        self.clvBooking.layer.borderWidth = 0.5
        self.clvBooking.layer.borderColor = UIColor.blackColor().CGColor
        
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
        
        dropStylist.placeholder = "Chọn stylist(không bắt buộc)"
        dropSalon.options = self.salonList
        dropTime.options = ["Hôm nay \(self.format(self.getDate(self.getTime(0.0))))",
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
        
        self.txtName.text = "Nguyen Van A"
        self.txtPhone.text = "0123456789"
    }
    
    //MARK: CollectionView
    func configCollectionView() {
        _ = self.dataVar.asObservable().bindTo(self.clvBooking.rx_itemsWithCellIdentifier("BookingCell", cellType: BookingCell.self)) {
            row,data,cell in
            cell.lblTime.text = "\(data.hour)"
            
            _ = self.statusDate.asObservable().subscribeNext {
                status in
                
                if self.checkDate(self.getDay(status), month: self.getMonth(status), year: self.getYear(status), hour: self.getHour(data.hour), minute: self.getMinute(data.hour)) {
                    cell.backgroundColor = UIColor(netHex: 0x008040)
                    cell.lblTime.textColor = UIColor.whiteColor()
                    cell.lblStatus.textColor = UIColor.whiteColor()
                    cell.lblStatus.text = "Còn chỗ"
                    data.canBooking = true
                    
                }
                else if data.currentSlot == data.slot {
                    cell.backgroundColor = UIColor(netHex: 0xFF5E3A)
                    cell.lblTime.textColor = UIColor.whiteColor()
                    cell.lblStatus.textColor = UIColor.whiteColor()
                    cell.lblStatus.text = "Hết chỗ"
                    data.canBooking = false
                }
                else {
                    cell.backgroundColor = UIColor(netHex: 0xDBDDDE)
                    cell.lblStatus.textColor = UIColor.blackColor()
                    cell.lblTime.textColor = UIColor.blackColor()
                    cell.lblStatus.text = "Nghỉ"
                    data.canBooking = false
                }
            }
            
            cell.layer.cornerRadius = 5.0
            cell.clipsToBounds = true
        }
        
        _ = self.clvBooking.rx_itemSelected.subscribeNext {
            indexPath in
            let cell = self.dataVar.value[indexPath.row]
            if cell.canBooking {
                self.bookingTimeId.value = cell.id
                for cell in self.clvBooking.visibleCells() {
                    cell.layer.borderWidth = 0.0
                }
                self.clvBooking.cellForItemAtIndexPath(indexPath)?.layer.borderColor = UIColor.blackColor().CGColor
                self.clvBooking.cellForItemAtIndexPath(indexPath)?.layer.borderWidth = 1.0
            }
            
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
        let date = today.dateByAddingTimeInterval((time)*24 * 60 * 60)
        
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
    
    func getDay(time : Double) -> Int {
        let today = NSDate()
        let date = today.dateByAddingTimeInterval((time)*24 * 60 * 60)
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        return components.day
    }
    
    func getMonth(time : Double) -> Int {
        let today = NSDate()
        let date = today.dateByAddingTimeInterval((time)*24 * 60 * 60)
        
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        return components.month
    }
    
    func getYear(time : Double) -> Int {
        let today = NSDate()
        let date = today.dateByAddingTimeInterval((time)*24 * 60 * 60)
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        return components.year
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
    
    func toDate(time : Double) -> String {
        return "\(self.getDay(time))-\(self.getMonth(time))-\(self.getYear(time))"
    }
    
    func checkTime(hour : Int, minute : Int) -> Bool {
        let h = NSCalendar.currentCalendar().component(NSCalendarUnit.Hour, fromDate: NSDate())
        let m = NSCalendar.currentCalendar().component(NSCalendarUnit.Minute, fromDate: NSDate())
        
        if hour > h + 1 || (hour == h + 1 && 60 - m + minute >= 15) {
            return true
        }
        else if h == hour {
            if minute - m >= 15 {
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
        self.statusSalonId.value = self.salonId[index]
        self.parseStylist(self.salonId[index]) {
            () in
            self.dropStylist.options = []
            self.stylistId = []
            for stylist in self.stylistVar.value {
                self.dropStylist.options.append(stylist.fullName)
                self.stylistId.append(stylist.id)
            }
            
        }
        
    }
}

extension BookingViewController : UIDropDownTimeDelegate {
    func dropDownTime(dropDown: UIDropDownTime, didSelectOption option: String, atIndex index: Int){
        if self.dateCount > 0 {
            self.statusDate.value = Double(index)
            if choseStylist {
                self.parseSchedule(self.statusSalonId.value, workDate: self.toDate(self.statusDate.value), stylistId: self.stylistId[self.statusStylistIndex.value]) {
                    () in
                    print(self.statusDate.value)
                    print("salonId \(self.statusSalonId.value)")
                    print("workDate \(self.toDate(self.statusDate.value))")
                    print("stylistId \(self.stylistId[self.statusStylistIndex.value])")
                    
                }
            }
            else {
                self.parseSchedule(self.statusSalonId.value, workDate: self.toDate(self.statusDate.value), stylistId: 0) {
                    () in
                    print(self.statusDate.value)
                    print("salonId \(self.statusSalonId.value)")
                    print("workDate \(self.toDate(self.statusDate.value))")
                    print("stylistId \(self.stylistId[self.statusStylistIndex.value])")
                    
                }
            }
        }
        self.dateCount += 1
    }
}

extension BookingViewController : UIDropDownStylistDelegate {
    func dropDownStylist(dropDown: UIDropDownStylist, didSelectOption option: String, atIndex index: Int){
        if stylistCount > 0 {
            self.statusStylistIndex.value = index
        }
        
        self.choseStylist = true
        self.parseSchedule(self.statusSalonId.value, workDate: self.toDate(self.statusDate.value), stylistId: stylistId[index]) {
            () in
            self.stylistCount += 1
            print("salonId \(self.statusSalonId.value)")
            print("workDate \(self.toDate(self.statusDate.value))")
            print("stylistId \(self.stylistId[index])")
        }
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
    
    func parseStylist(salonId : Int,completion : ()->()) {
        let GET_STYLIST_API = "http://api.30shine.com/staff/stylist"
        let parameter = ["SalonId":salonId]
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



