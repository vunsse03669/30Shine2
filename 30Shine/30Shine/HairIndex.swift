//
//  HairIndex.swift
//  30Shine
//
//  Created by Apple on 8/17/16.
//  Copyright © 2016 vu. All rights reserved.
//

import Foundation

class HairIndex {
    static let shareInstance = HairIndex()
    private var index: Int! = 0
    private init() {
        self.index = 0
    }
    
    func setIndex(index : Int) {
        self.index = index
    }
    
    func getIndex() -> Int {
        return index
    }
}