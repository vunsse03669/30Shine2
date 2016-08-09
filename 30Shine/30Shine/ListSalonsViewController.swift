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
        var image = UIImage(named: "img-back")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleBackButton))
    }
    
    func handleBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    func setupContent(){
        listSalon = ListSalonView.createInView(self.view)
        listSalon.navigation = self.navigationController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
