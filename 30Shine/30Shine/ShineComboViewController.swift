//
//  ShineComboViewController.swift
//  30Shine
//
//  Created by Đỗ Ngọc Trình on 8/8/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class ShineComboViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewShineCombo: UIView!
    
    var shineComboView : ShineComboView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shineComboView = ShineComboView.createInView(self.viewShineCombo)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
