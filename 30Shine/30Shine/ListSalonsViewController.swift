//
//  ListSalonsViewController.swift
//  30Shine
//
//  Created by Đỗ Ngọc Trình on 8/5/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class ListSalonsViewController: UIViewController {

    var listSalon : ListSalonView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
        // Do any additional setup after loading the view.
    }
    
    func setupContent(){
        listSalon = ListSalonView.createInView(self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
