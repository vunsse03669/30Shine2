//
//  SalonsViewController.swift
//  30Shine
//
//  Created by Đỗ Ngọc Trình on 8/5/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class SalonsViewController: UIViewController, UIPageViewControllerDataSource{

    let salonPageViewController = SalonPageViewController()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let salonContent = SalonContentViewController(nibName: "SalonContentViewController",  bundle: nil)
        self.salonPageViewController.dataSource = self
        let salonContents = [salonContent]
        self.salonPageViewController.setViewControllers(salonContents, direction: .Forward, animated: true) { (bool) in
            print("page content ")
        }
        self.addChildViewController(salonPageViewController)
        self.view.addSubview(salonPageViewController.view)
        salonPageViewController.view.center = self.view.center
        salonPageViewController.view.frame = self.view.frame
        salonPageViewController.didMoveToParentViewController(self)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
       return 0
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {

        return 0
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let pageContent = SalonContentViewController(nibName: "SalonContentViewController", bundle: nil)
        print("countbefore")
        return pageContent
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let pageContent = SalonContentViewController(nibName: "SalonContentViewController", bundle: nil)
        print("countafter")
        return pageContent
    }
}
