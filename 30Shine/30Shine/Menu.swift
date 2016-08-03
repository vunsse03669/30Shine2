//
//  Menu.swift
//  30Shine
//
//  Created by Mr.Vu on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RealmSwift

class Menu: Object {
    
    dynamic var imageName : String = ""
    dynamic var title     : String = ""

    static func create(title : String, imageName : String) -> Menu{
        let menu = Menu()
        menu.title = title
        menu.imageName = imageName
        self.createMenu(menu)
        return menu
    }
}

extension Menu {
    static func createMenu(menu : Menu) {
        try! sDB.realm.write {
            sDB.realm.add(menu)
        }
    }
    
    static func getMenuByTitle(title : String) -> Menu! {
        let predicate = NSPredicate(format: "title = %@", title)
        return sDB.realm.objects(Menu).filter(predicate).first
    }
    
    static func getAllMenu() -> [Menu] {
        var menus = [Menu]()
        for menu in sDB.realm.objects(Menu) {
            menus.append(menu)
        }
        return menus
    }
}
