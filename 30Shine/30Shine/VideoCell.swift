//
//  VideoCell.swift
//  30Shine
//
//  Created by Mr.Vu on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {
    
    @IBOutlet weak var lblNote: UILabel!
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
    
    func caculateDeltaTime(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> String {
        let deltaYear = getYear(0) - year
        let deltaMonth = getMonth(0) - month
        let deltaDay = getDay(0) - day
        let deltaHour = getHour(0) - hour
        let deltaMinute = getMinute(0) - minute
        
        if deltaYear > 1 {
            return "\(deltaYear) years ago"
        }
        else if deltaYear == 1 {
            return "a year ago"
        }
        else {
            if deltaMonth > 1 {
                return "\(deltaMonth) months ago"
            }
            else if deltaMonth == 1 {
                return "a month ago"
            }
            else {
                if deltaDay > 1 {
                    return "\(deltaDay) days ago"
                }
                else if deltaDay == 1 {
                    return "a day ago"
                }
                else {
                    if deltaHour > 1 {
                        return "\(deltaHour) hours ago"
                    }
                    else if deltaHour == 1 {
                        return "a hour ago"
                    }
                    else {
                        if deltaMinute > 1 {
                            return "\(deltaMinute) minutes ago"
                        }
                        else if deltaMinute == 1 {
                            return "a minute ago"
                        }
                        else {
                            return "Just now"
                        }
                    }
                }
                
            }
        }
    }
    
    func getDateString(day : String) -> String {
        var str = ""
        for c in day.characters {
            str.append(c)
            if c == " " {
                break
            }
        }
        return str
    }
    
    func caculateTime(str : String) -> String {
        var day = ""
        var month = ""
        var year = ""
        var hour = ""
        var minute = ""
        
        var count = 0
        for c in str.characters {
            if c == " " {
                count += 1
                continue
            }
            if c == "-" {
                count += 1
            }
            else if c == ":" {
                count += 1
            }
            
            switch count {
            case 0:
                year.append(c)
            case 1:
                month.append(c)
            case 2:
                day.append(c)
            case 3:
                hour.append(c)
            case 4:
                minute.append(c)
            default:
                print("")
            }
        }
        day = day.stringByReplacingOccurrencesOfString("-", withString: "")
        month = month.stringByReplacingOccurrencesOfString("-", withString: "")
        year = year.stringByReplacingOccurrencesOfString("-", withString: "")
        hour = hour.stringByReplacingOccurrencesOfString(" ", withString: "")
        minute = minute.stringByReplacingOccurrencesOfString(" ", withString: "")
        print("year: \(Int(year))")
        print("month: \(Int(month))")
        print("day: \(Int(day))")
        print("hour: \(Int(hour))")
        print("minute: \(minute)")
        
        return caculateDeltaTime(Int(year)!, month:Int(month)! , day: Int(day)!, hour: Int(hour)!, minute: 10)
       
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
    
    func getHour(time : Double) -> Int {
        let today = NSDate()
        let date = today.dateByAddingTimeInterval((time)*24 * 60 * 60)
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        return components.hour
    }
    
    func getMinute(time : Double) -> Int {
        let today = NSDate()
        let date = today.dateByAddingTimeInterval((time)*24 * 60 * 60)
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        return components.minute
    }
    
    func toDateString(time : Double) -> String {
        return "\(self.getDay(time))-\(self.getMonth(time))-\(self.getYear(time))"
    }

}
