//
//  DB.swift
//  30Shine
//
//  Created by Mr.Vu on 7/23/16.
//  Copyright © 2016 vu. All rights reserved.
//

import RealmSwift

let sDB = DB.Singleton

class DB: NSObject {
    private static let Singleton = DB()
    private override init() {}

    let realm : Realm = try! Realm()
}
