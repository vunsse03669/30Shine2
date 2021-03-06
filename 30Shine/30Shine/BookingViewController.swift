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
import ReachabilitySwift

class BookingViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var clvBooking: UICollectionView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblSalon: UILabel!
    @IBOutlet weak var lblStylist: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblBookTime: UILabel!
    
    @IBOutlet weak var clvBookingHeightConstraint: NSLayoutConstraint!
    
    var dropSalon   : UIDropDown!
    var dropTime    : UIDropDownTime!
    var dropStylist : UIDropDownStylist!
    
    var salonId = 2
    var stylistId : [Int] = [0]
    var salonIds  : [Int] = [2,3,4,5]
    var salonList : [String] = ["346 Khâm Thiên",
                                "82 Trần Đại Nghĩa",
                                "235 Đội Cấn",
                                "702 Đường Láng"]
    var stringBookingTime = ""
    
    var salontCount   = 0
    var dateCount     = 0
    var stylistCount  = 0
    var salonCount    = 0
    var reachability: Reachability?
    
    var bookingTimeId : Variable<Int> = Variable(0)
    var dataVar       : Variable<[Booking]> = Variable([])
    var stylistVar    : Variable<[Stylist]> = Variable([])
    var statusDate    : Variable<Double> = Variable(0)
    var statusSalonId : Variable<Int> = Variable(0)
    var stylistID     : Variable<Int> = Variable(0)
    var workTimeList  : Variable<[Int]> = Variable([])
    
    var isClickOnSalon   = Variable(0)
    var isClickOnTime    = Variable(0)
    var isClickOnStylist = Variable(0)
    
    func resetStylistAndWorkTime() -> Void {
        stylistID.value = -1
        bookingTimeId.value = -1
    }
    
    func checkInternet() {
        do {
            reachability = try! Reachability.reachabilityForInternetConnection()
        }
        reachability!.whenUnreachable = {
            reachability in
            dispatch_async(dispatch_get_main_queue()) {
                let message = "Hiện tại thiết bị của bạn đang không được kết nối internet. Quý khách muốn dùng chức năng này xin vui lòng kiểm tra lại kết nối internet!"
                let alert = UIAlertView(title: "", message: message, delegate: self, cancelButtonTitle: "Xác nhận")
                alert.show()
            }
        }
        try! reachability?.startNotifier()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkInternet()
        self.configUI()
        self.configCollectionView()
        self.parseSchedule(salonId, workDate: self.toDate(0), stylistId: 0) {}
        
        //binding data if login
        if self.isLogin() {
            self.bindingData()
        }
        
        // Add Hide keyboard observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BookingViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BookingViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //Click on button Back
        _ = btnHome.rx_tap
            .subscribeNext {
                self.navigationController?.popViewControllerAnimated(true)
        }
        
        self.addRightButton {
            if self.isLogin() {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SelectProfileController") as! SelectProfileController
                self.navigationController?.push(vc, animated: true)
            }
            else {
                self.showAlert("Bạn chưa đăng nhập", message: "Mời quý khách đăng nhập/đăng ký tài khoản để sử dụng đầy đủ chức năng của ứng dụng!")
            }
        }
        
        
        //Click on button submit
        _ = btnSubmit.rx_tap.subscribeNext {
            print("Name : \(self.txtName.text!)")
            print("Phone: \(self.txtPhone.text!)")
            print("Salon id: \(self.statusSalonId.value)")
            print("Date : \(self.toDate(self.statusDate.value))")
            print("Stylist id : \(self.stylistID.value)")
            print("HourId : \(self.bookingTimeId.value)")
            
            if (self.bookingTimeId.value == -1) {
                self.alertMessage("", msg: "Quí khách làm ơn chọn khung giờ sử dụng dịch vụ")
                return
            }
            
            let name      = self.txtName.text!
            let phone     = self.txtPhone.text!
            let salonId   = String(self.statusSalonId.value)
            let date      = self.toDate(self.statusDate.value)
            let stylistId = String(self.stylistID.value)
            let hourId    = String(self.bookingTimeId.value)
            
            if self.validate(name, phone: phone, date: date, hourId: hourId) {
                print("booking")
                sNetworkSender.sendBooking(name, phone: phone, salonID: salonId, dateBook: date, StylistId: stylistId, hourId: hourId,completion: {
                    Bool in
                    if(Bool){
                        print("DONE")
                        self.alertMessage("Đặt lịch thành công", msg: "Hẹn gặp quý khách tại 30Shine!")
                        
                        self .createLocalAlert()
                    }
                    else{
                        self.alertMessage("Lỗi đặt lịch", msg: "Đã có lỗi trong quá trình đặt lịch, quý khách vui lòng đặt lại")
                        print("ERROR")
                    }
                    return Bool
                })
            }
            else {
                self.alertMessage("Thông báo", msg: "Đã xảy ra sự cố trong quá trình đặt lịch.Quý khách vui lòng thực hiện lại!")
            }
        }
    }
    func createLocalAlert(){
        let notification = UILocalNotification()
        
        // notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        
        let timeCountDown = timeDate(dateFromString(self.stringBookingTime))
        
        if(timeCountDown > 0){
            
            notification.fireDate = NSDate(timeIntervalSinceNow: timeCountDown)
            
            //let cell = self.dataVar.value[indexPath.row]
            let indexPaths : NSArray = self.clvBooking!.indexPathsForSelectedItems()!
            let indexPath : NSIndexPath = indexPaths[0] as! NSIndexPath
            let time = self.dataVar.value[indexPath.row].hour;
            
            if #available(iOS 8.2, *) {
                notification.alertTitle = "Lịch cắt tóc lúc \(time)"
            } else {
                // Fallback on earlier versions
            }
            notification.alertBody = " Anh \(Login.getLogin().fullName) ơi, anh có hẹn cắt tóc lúc \(time) tại salon \(self.dropSalon.options[self.dropSalon.selectedIndex!]), anh nhớ đến đúng giờ nha!"
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
        else{
            print("TIME REMIND < \(TIME_BOOKING_REMINDER)'. Do nothing")
        }
        
    }
    
    func dateFromString(string : String) -> NSDate{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        //    dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
        //    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        //    dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let dateFromString = dateFormatter.dateFromString(string)
        return dateFromString!
    }
    
    func timeDate(date : NSDate) -> NSTimeInterval{
        let timeCount = date.timeIntervalSinceDate(NSDate())
        return timeCount - TIME_BOOKING_REMINDER*60
    }

    //Validate
    func validate(name : String, phone: String, date : String, hourId : String) -> Bool {
        if name == "" || phone == "" || date == "" || hourId == "0" {
            return false
        }
        else if phone.characters.count < 10 && phone.characters.count > 11 {
            return false
        }
        return true
    }
    
    //MARK: hide keyboard
    func keyboardWillShow(notification: NSNotification) {
        self.hideKeyboardWhenTappedAround()
    }
    
    func keyboardWillHide(notification: NSNotification) {
        for recognizer in view.gestureRecognizers ?? [] {
            view.removeGestureRecognizer(recognizer)
        }
    }
    
    //MARK: UI
    func configUI() {
        let logo        = UIImage(named: "logo")
        let imageView   = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        
        self.navigationItem.titleView = imageView
        self.scrollView.bringSubviewToFront(self.vContainer)
        
        self.clvBooking.layer.zPosition    = -1000
        self.clvBooking.layer.borderWidth  = 0.5
        self.clvBooking.layer.borderColor  = UIColor(netHex: 0xD7D7D7).CGColor
        self.clvBooking.layer.cornerRadius = 5.0
        self.btnSubmit.layer.cornerRadius  = 5.0
        
        self.txtPhone.layer.borderColor = UIColor(netHex: 0xD7D7D7).CGColor
        self.txtPhone.layer.borderWidth = 1.0
        self.txtPhone.clipsToBounds     = true
        self.txtPhone.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        self.txtPhone.keyboardType = .DecimalPad
        
        self.txtName.layer.borderWidth = 1.0
        self.txtName.layer.borderColor = UIColor(netHex: 0xD7D7D7).CGColor
        self.txtName.clipsToBounds     = true
        self.txtName.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        self.lblName.mutiColor("* Họ tên:", startAt: 0, range: 1, color: .redColor())
        self.lblPhone.mutiColor("* SĐT:", startAt: 0, range: 1, color: .redColor())
        self.lblSalon.mutiColor("* Salon:", startAt: 0, range: 1, color: .redColor())
        self.lblDate.mutiColor("* Ngày:", startAt: 0, range: 1, color: .redColor())
        self.lblBookTime.mutiColor("* Giờ hẹn:", startAt: 0, range: 1, color: .redColor())
        
        self.configDropDownList()
        self.configCollectionViewLayout()
        BookingNotificatioView.createView(self.view)
        
    }
    
    func configDropDownList() {
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
        let index = self.salonIds.indexOf(self.salonId)
        dropSalon.setSelectedIndex(index!)
        
        dropTime.hideOptionsWhenSelect = true
        dropSalon.hideOptionsWhenSelect = true
        dropStylist.hideOptionsWhenSelect = true
        
        self.isClickOnTime = dropTime.isClick
        self.isClickOnSalon = dropSalon.isClick
        self.isClickOnStylist = dropStylist.isClick
        
        self.hideTableOfDropDown()
    }
    
    func hideTableOfDropDown() {
        _ = self.isClickOnStylist.asObservable().subscribeNext { isClick in
            if isClick > 0 {
                if self.dropSalon.selected {
                    self.dropSalon.hideTable()
                }
                if self.dropTime.selected {
                    self.dropTime.hideTable()
                }
            }
        }
        
        _ = self.isClickOnSalon.asObservable().subscribeNext { isClick in
            if isClick > 0 {
                if self.dropStylist.selected {
                    self.dropStylist.hideTable()
                }
                if self.dropTime.selected {
                    self.dropTime.hideTable()
                }
            }
        }
        
        _ = self.isClickOnTime.asObservable().subscribeNext { isClick in
            if isClick > 0 {
                if self.dropSalon.selected {
                    self.dropSalon.hideTable()
                }
                if self.dropStylist.selected {
                    self.dropStylist.hideTable()
                }
                
            }
        }
    }
    
    //MARK: bingding data for txtPhone, name
    func bindingData() {
        if Login.getLogin().phone != ""  {
            self.txtPhone.text = Login.getLogin().phone
        }
        if Login.getLogin().fullName != "" {
            self.txtName.text = Login.getLogin().fullName
        }
    }
    
    //MARK: CollectionView
    func configCollectionView() {
        
//        [self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL
        
        self.clvBooking.addObserver(self, forKeyPath: "contentSize", options:.Old, context: nil)
        
        _ = self.dataVar.asObservable().bindTo(self.clvBooking.rx_itemsWithCellIdentifier("BookingCell", cellType: BookingCell.self)) {
            row,data,cell in
            cell.lblTime.text = "\(data.hour)"
            
            _ = self.statusDate.asObservable().subscribeNext {
                status in
                if  self.stylistID.value == 0 {
                    if self.checkDate(self.getDay(status), month: self.getMonth(status), year: self.getYear(status), hour: self.getHour(data.hour), minute: self.getMinute(data.hour)) {
                        self.haveSlot(cell)
                        data.canBooking = true
                        
                    }
                    else {
                        self.desist(cell)
                        data.canBooking = false
                    }
                    
                    if data.currentSlot >= data.slot {
                        self.fullSlot(cell)
                        data.canBooking = false
                    }
                    
                }
                else {
                    switch data.statusBooking {
                    case 0:
                        self.desist(cell)
                        data.canBooking = false
                    case 1:
                        self.fullSlot(cell)
                        data.canBooking = false
                    case 2:
                        self.haveSlot(cell)
                        data.canBooking = true
                    default:
                        print("failded")
                    }
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
                for cell in self.clvBooking.visibleCells() as! [BookingCell] {
                    if cell.canBooking {
                        cell.backgroundColor = UIColor(netHex: 0x4FAC4B)
                    }
                }
                self.clvBooking.cellForItemAtIndexPath(indexPath)?.backgroundColor = UIColor(netHex: 0x1AD6FD)
                self.stringBookingTime = "\(self.toDate(self.statusDate.value)) \(cell.hour.stringByReplacingOccurrencesOfString("h", withString: ":"))";
                print("\(self.stringBookingTime)")
                print(self.timeDate( self.dateFromString(self.stringBookingTime)))
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.clvBookingHeightConstraint.constant = self.clvBooking.contentSize.height
    }
    
    func configCollectionViewLayout() {
        self.vContainer.layoutIfNeeded()
        self.clvBooking.layoutIfNeeded()
        
        let layout : UICollectionViewFlowLayout! = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        
        let width = self.vContainer.bounds.width/4 - 12
        let height = 0.6 * width
        
        layout.itemSize = CGSizeMake(width, height)
        self.clvBooking.setCollectionViewLayout(layout, animated: true)
    }
    
    func haveSlot(cell : BookingCell) {
        cell.backgroundColor     = UIColor(netHex: 0x4FAC4B)
        cell.lblTime.textColor   = UIColor.whiteColor()
        cell.lblStatus.textColor = UIColor.whiteColor()
        cell.lblStatus.text      = "Còn chỗ"
        cell.canBooking          = true
    }
    
    func fullSlot(cell : BookingCell) {
        cell.backgroundColor     = UIColor(netHex: 0xB3322E)
        cell.lblTime.textColor   = UIColor.whiteColor()
        cell.lblStatus.textColor = UIColor.whiteColor()
        cell.lblStatus.text      = "Hết chỗ"
        cell.canBooking = false
        
    }
    
    func desist(cell : BookingCell) {
        cell.backgroundColor     = UIColor(netHex: 0xC1C1C1)
        cell.lblStatus.textColor = UIColor.blackColor()
        cell.lblTime.textColor   = UIColor.blackColor()
        cell.lblStatus.text      = "Nghỉ"
        cell.canBooking          = false
    }
    
    
}

//MARK : Change text field value
extension BookingViewController : UIDropDownDelegate {
    func dropDown(dropDown: UIDropDown, didSelectOption option: String, atIndex index: Int) {
        self.resetStylistAndWorkTime()
        self.statusSalonId.value = self.salonIds[index]
        
        self.parseStaffAttendace(self.statusSalonId.value, workDate: self.toDate(self.statusDate.value)) {
            () in
            self.parseStylist(self.salonIds[index]) {
                () in
                self.dropStylist.options = []
                self.stylistId = []
                for stylist in self.stylistVar.value {
                    if self.workTimeList.value.contains(stylist.id) {
                        self.dropStylist.options.append(stylist.fullName)
                    }
                    else {
                        self.dropStylist.options.append("\(stylist.fullName) (nghỉ)")
                    }
                    
                    self.stylistId.append(stylist.id)
                }
                self.dropStylist.placeholder = "Chọn Stylist( Không bắt buộc)"
                self.dropStylist.selectedIndex = -1
                self.stylistID.value = 0
            }
        }
        
        
        if self.salonCount > 0 {
            self.parseSchedule(self.statusSalonId.value, workDate: self.toDate(self.statusDate.value), stylistId: 0) {
                
                print(self.statusDate.value)
                print("salonId \(self.statusSalonId.value)")
                print("workDate \(self.toDate(self.statusDate.value))")
                print("stylistId 0)")
                
            }
        }
        self.salonCount += 1
    }
}

extension BookingViewController : UIDropDownTimeDelegate {
    func dropDownTime(dropDown: UIDropDownTime, didSelectOption option: String, atIndex index: Int){
        self.resetStylistAndWorkTime()
        if self.dateCount > 0 {
            self.statusDate.value = Double(index)
            self.parseSchedule(self.statusSalonId.value, workDate: self.toDate(self.statusDate.value), stylistId: self.stylistID.value) {
                
                print(self.statusDate.value)
                print("salonId \(self.statusSalonId.value)")
                print("workDate \(self.toDate(self.statusDate.value))")
                print("stylistId \(self.stylistID.value)")
            }
        }
        self.dateCount += 1
    }
}

extension BookingViewController : UIDropDownStylistDelegate {
    func dropDownStylist(dropDown: UIDropDownStylist, didSelectOption option: String, atIndex index: Int) {
        self.bookingTimeId.value = -1
        
        self.stylistID.value = self.stylistId[index]
        self.parseSchedule(self.statusSalonId.value, workDate: self.toDate(self.statusDate.value), stylistId: self.stylistID.value) {
            
            self.stylistCount += 1
            print("salonId \(self.statusSalonId.value)")
            print("workDate \(self.toDate(self.statusDate.value))")
            print("stylistId \(self.stylistID.value)")
        }
    }
}

//MARK: Parse Json
extension BookingViewController {
    func parseSchedule(salonId : Int, workDate : String, stylistId : Int, compeletion : () ->()) {
        
        let BOOKING_API = "http://api.30shine.com/booking/dsbookhour/stylist"
        let parameter = ["SalonId":salonId,"WorkDate":workDate,"Stylist":stylistId]
        self.dataVar.value = []
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            Alamofire.request(.POST, BOOKING_API, parameters: parameter as? [String : AnyObject], encoding: .JSON).responseJASON {
                response in
                if let json = response.result.value {
                    let bookings = json["d"].map(BookingNetwork.init)
                    for booking in bookings {
                        let data = Booking(id: booking.id, hour: booking.hour, status: "", slot: booking.slot, hourFrame: booking.hourFrame, salonId: booking.salonId, currentSlot: booking.currentSlot, stylistCurrentSlot: booking.stylistCurrentSlot,statusBooking : booking.statusBooking)
                        print(data.statusBooking)
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
    
    func parseStaffAttendace(salonId : Int, workDate : String, completion:()->()) {
        
        let API = "http://api.30shine.com/staff/stylisttoworkdate"
        let parameters = ["SalonId" : salonId, "WorkDate" : workDate]
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            Alamofire.request(.POST, API, parameters: parameters as? [String : AnyObject], encoding: .JSON)
                .responseJASON {
                    response in
                    if let json = response.result.value {
                        let hourIds = json["d"].map(StylistWorkTime.init)
                        for hourId in hourIds {
                            self.workTimeList.value.append(hourId.staffId)
                        }
                        completion()
                    }
            }
        }
    }
}

//MARK: Alertview delegate
extension BookingViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        if buttonIndex == 1 {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginController") as! LoginController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func showAlert(title : String, message : String) {
        let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "Để sau", otherButtonTitles: "Đăng nhập")
        alert.show()
    }
}


//MARK:  Helper
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
        
        if hour > h + 1 || (hour == h + 1 && 60 - m + minute >= BOOKING_TIME_MARGIN) {
            return true
        }
        else if h == hour {
            if minute - m >= BOOKING_TIME_MARGIN {
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
    
    func alertMessage(title : String, msg : String) {
        let alert = UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: "Xác nhận")
        alert.show()
    }
}




