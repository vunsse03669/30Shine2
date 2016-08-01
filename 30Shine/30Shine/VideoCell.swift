//
//  VideoCell.swift
//  30Shine
//
//  Created by Mr.Vu on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var imvThumnail: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
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

}
