//
//  StringExtensions.swift
//  30Shine
//
//  Created by Apple on 9/14/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation

extension String {
    func toDate(format : String = "dd-MM-yyy") -> NSDate? {
        let  dateFormatter = NSDateFormatter()
        return dateFormatter.dateFromString(self)
    }
}