//
//  StringExtensions.swift
//  30Shine
//
//  Created by Apple on 9/14/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation

extension String {
    func toDate(format : String = "dd/MM/yyyy") -> NSDate? {
        let  dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.dateFromString(self)
    }
}