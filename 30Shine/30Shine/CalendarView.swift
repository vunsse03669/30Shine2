//
//  CalendarView.swift
//  30Shine
//
//  Created by Apple on 8/17/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol CalendarDelegate {
    func didPickDate(date : NSDate)
}

class CalendarView: UIView {

    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate : CalendarDelegate!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupPicker()
        
        //Click Cancel button
        _ = self.btnCancel.rx_tap.subscribeNext {
            UIView.animateWithDuration(0.5, animations: {
                self.frame = CGRectMake(0, 800, self.frame.size.width, self.frame.size.height)
            }) { (animated) in
                self.removeFromSuperview()
            }
        }
        
        //Click Done button
        _ = self.btnDone.rx_tap.subscribeNext {
            if self.delegate != nil {
                self.delegate.didPickDate(self.datePicker.date)
            }
            
            UIView.animateWithDuration(0.5, animations: {
                self.frame = CGRectMake(0, 800, self.frame.size.width, self.frame.size.height)
            }) { (animated) in
                self.removeFromSuperview()
            }
        }
    }
    
    static func createView(superView : UIView) -> CalendarView! {
        let calendarView : CalendarView! = NSBundle.mainBundle().loadNibNamed("CalendarView", owner: self, options: nil) [0] as! CalendarView
        
        calendarView.frame = CGRectMake(0, 800, 1,1)
        UIView.animateWithDuration(0.5) {
            calendarView.frame = CGRectMake(0, 0, superView.frame.size.width, superView.frame.size.height)
        }
        superView.addSubview(calendarView)
        return calendarView
    }
    
    func setupPicker() {
        datePicker.datePickerMode = UIDatePickerMode.Date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        //let selectedDate = dateFormatter.stringFromDate(datePicker.date)
    }

}
