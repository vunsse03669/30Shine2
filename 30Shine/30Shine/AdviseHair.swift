//
//  AdviseHair.swift
//  30Shine
//
//  Created by Apple on 8/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import RealmSwift

class AdviseHair: Object {
    dynamic var hairAttribute : String = ""
    dynamic var descriptionn : String = ""
    dynamic var dateConsultant : String = ""
    var product : List<Product> = List<Product>()
    
    static func create(description : String, date : String, product : List<Product>, hairAttribute : String) -> AdviseHair {
        let adviseHair = AdviseHair()
        adviseHair.hairAttribute = hairAttribute
        adviseHair.descriptionn = description
        adviseHair.dateConsultant = date
        adviseHair.product = product
        self.createAdviseHair(adviseHair)
        return adviseHair
    }
}

extension AdviseHair {
    static func createAdviseHair(adviseHair : AdviseHair) {
        try! sDB.realm.write {
            sDB.realm.add(adviseHair)
        }
    }
    
    static func getAdviseHairByDate(date : String) -> AdviseHair! {
        let predicate = NSPredicate(format: "dateConsultant = %@", date)
        return sDB.realm.objects(AdviseHair).filter(predicate).first
    }
    
    static func getAdviseHair() -> AdviseHair! {
        return sDB.realm.objects(AdviseHair).first
    }
}

class Product : Object {
    dynamic var id : Int = 0
    dynamic var productName : String  = ""
    dynamic var price : Int = 0
    dynamic var thumb : String = ""
    
    static func create(id : Int, productName : String, price : Int, thumb : String) -> Product {
        let product = Product()
        product.id = id
        product.productName = productName
        product.price = price
        product.thumb = thumb
        self.createProduct(product)
        return product
    }
    
    static func createProduct(product : Product) {
        try! sDB.realm.write {
            sDB.realm.add(product)
        }
    }
    
    static func getProductById(id : Int) -> Product! {
        let predicate = NSPredicate(format: "id = %d", id)
        return sDB.realm.objects(Product).filter(predicate).first
    }
    
    static func getAllProduct() -> [Product] {
        var products = [Product]()
        for product in sDB.realm.objects(Product) {
            products.append(product)
        }
        return products
    }
}
