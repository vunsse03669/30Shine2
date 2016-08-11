//
//  LoginNetwork.swift
//  30Shine
//
//  Created by Apple on 8/11/16.
//  Copyright © 2016 vu. All rights reserved.
//

import JASON

struct LoginNetwork {
    let id : Int
    let phone : String
    let fullname : String
    let email : String
    let accessToken : String
    let dob : Int
    let mob : Int
    let yob : Int
    
    init(_ json : JSON) {
        id          = json[.login_id]
        phone       = json[.login_phone]
        fullname    = json[.login_fullname]
        email       = json[.login_email]
        accessToken = json[.login_accessToken]
        dob         = json[.login_dob]
        mob         = json[.login_mob]
        yob         = json[.login_yob]
    }
}
