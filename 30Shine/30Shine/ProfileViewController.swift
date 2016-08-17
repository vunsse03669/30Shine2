//
//  ProfileViewController.swift
//  30Shine
//
//  Created by Mr.Vu on 7/23/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import NPSegmentedControl

class ProfileViewController: UIViewController {
   
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    
    var historyView : CustomerHistoryView!
    var currentTab = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.configContent()

        //back to home
        _ = btnHome.rx_tap
            .subscribeNext {
                self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
    }
    
    func configContent() {
        self.historyView = CustomerHistoryView.createView(self.vContainer)
    }
    
}
