//
//  Login.swift
//  30Shine
//
//  Created by Apple on 8/11/16.
//  Copyright © 2016 vu. All rights reserved.
//

import RealmSwift

class Login: Object {
    dynamic var id = 0
    dynamic var phone = ""
    dynamic var fullName = ""
    dynamic var email = ""
    dynamic var acessToken = ""
    dynamic var dayOfbirth = 0
    dynamic var monthOfBirth = 0
    dynamic var yearOfBirth = 0
    
    static func create(id : Int, phone : String, fullName : String, email : String, token : String, dob : Int, mob : Int, yob : Int) -> Login {
        let login = Login()
        login.id = id
        login.phone = phone
        login.fullName = fullName
        login.email = email
        login.acessToken = token
        login.dayOfbirth = dob
        login.monthOfBirth = mob
        login.yearOfBirth = yob
        self.createLogin(login)
        return login
    }
    
}

extension Login {
    static func createLogin(login : Login) {
        try! sDB.realm.write {
            sDB.realm.add(login)
        }
    }
    
    static func getLoginById(id : Int) -> Login! {
        let predicate = NSPredicate(format: "id = %d", id)
        return sDB.realm.objects(Login).filter(predicate).first
    }
    
    static func getLogin() -> Login! {
        return sDB.realm.objects(Login).first
    }
    
    static func updateLogin(login : Login, name : String, phone : String, email: String, dob : Int, mob : Int, yob : Int) {
        try! sDB.realm.write {
            login.fullName = name
            login.phone = phone
            login.email = email
            login.dayOfbirth = dob
            login.monthOfBirth = mob
            login.yearOfBirth = yob
        }
    }
    
    static func updateToken(login: Login,  token : String) {
        try! sDB.realm.write {
            login.acessToken = token
        }
    }
    
    static func deleteLogin() {
        try! sDB.realm.write {
            sDB.realm.deleteAll()
        }
    }
}
