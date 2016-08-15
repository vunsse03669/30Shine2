//
//  SalonTableCell.swift
//  30Shine
//
//  Created by Do Ngoc Trinh on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SalonTableCell: UITableViewCell {

    @IBOutlet weak var imvSalon: UIImageView!
    @IBOutlet weak var lblAdress: UILabel!
    @IBOutlet weak var lblManager: UILabel!
    @IBOutlet weak var lblHotLine: UILabel!
    @IBOutlet weak var lblFacebookLink: UILabel!
    
    @IBOutlet weak var btnBooking: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    
    var phone = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnCall.customButton()
        btnBooking.customButton()
        setupButton()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupButton(){
        _ = self.btnCall.rx_tap.subscribeNext{
            print("hotline \(self.phone)")
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(self.phone)")!)
        }
        _ = self.btnBooking.rx_tap.subscribeNext{
            
            let rootViewController = self.window!.rootViewController as! UINavigationController
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc : UIViewController!
            vc = mainStoryboard.instantiateViewControllerWithIdentifier("BookingViewController") as? BookingViewController
            rootViewController.pushViewController(vc, animated: true)
        }
    }
    
}
