//
//  ServicesViewController.swift
//  30Shine
//
//  Created by Đỗ Ngọc Trình on 8/8/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class ServicesViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tbvMenu: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
              
        
        self.tbvMenu.delegate = self
        self.tbvMenu.dataSource = self

        self.tbvMenu.tableFooterView = UIView()
                

        self.configUI()
    }
    
    func handleBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func handleProfile() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        self.navigationController?.push(vc, animated: true)
    }

    
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationController?.navigationBar.translucent = false
        //back image
        var backImage = UIImage(named: "img-back")
        backImage = backImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleBackButton))
        //profile image
        var profileImage = UIImage(named: "img-people")
        profileImage = profileImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: profileImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleProfile))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServiceMenuCell", forIndexPath: indexPath) as! ServiceMenuCell
        if indexPath.row == 0 {
            cell.lblTitle.text = "Shine Combo"
            cell.imv.image = UIImage(named: "khamthien1")
        }
        else{
            cell.lblTitle.text = "Dịch Vụ Khác"
            cell.imv.image = UIImage(named: "khamthien1")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        print("did tap");
        
        tableView .deselectRowAtIndexPath(indexPath, animated: true)

        var vc : UIViewController!
        if indexPath.row == 0 {
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("ShineComboViewController")
        }
        else{
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("OtherServicesViewController")
        }
        
        self.navigationController?.push(vc, animated: true)
        
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
