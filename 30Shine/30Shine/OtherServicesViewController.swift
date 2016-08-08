//
//  OtherServicesViewController.swift
//  30Shine
//
//  Created by Đỗ Ngọc Trình on 8/8/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class OtherServicesViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    var otherServices : OtherServicesView!
    
    @IBOutlet weak var viewOtherServices: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.otherServices = OtherServicesView.createInView(self.viewOtherServices)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
