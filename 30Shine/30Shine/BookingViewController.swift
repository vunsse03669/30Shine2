//
//  BookingViewController.swift
//  30Shine
//
//  Created by Mr.Vu on 7/26/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class BookingViewController: UIViewController {
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnHome: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        
        _ = btnHome.rx_tap
            .subscribeNext {
                self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    //MARK: UI
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
    }

}
