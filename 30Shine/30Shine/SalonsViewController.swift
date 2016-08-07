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
    var detailSalonView : DetailSalonView!
    
    var currentPageIndex : NSInteger!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let salonContent = SalonContentViewController(nibName: "SalonContentViewController",  bundle: nil)
        self.detailSalonView = DetailSalonView.createInView(salonContent.view)
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
        
        self.currentPageIndex = 0
    
    }
    
    
    /*
     #pragma mark - Page View Controller Data Source
     
     - (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
     {
     
     NSInteger index = ((ReviewPageContentVC*) viewController).pageindex;
     _currentPageIndex = index;
     self.navigationItem.title = [NSString stringWithFormat:@"%lu/%ld",index+1,_questions.count];
     [self checkTagForQuestion:_questions[index]];
     if ((index == 0) || (index == NSNotFound)) {
     return nil;
     }
     index--;
     
     return [self viewControllerAtIndex:index];
     }
     
     - (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
     {
     NSInteger index = ((ReviewPageContentVC*) viewController).pageindex;
     _currentPageIndex = index;
     [self checkTagForQuestion:_questions[index]];
     self.navigationItem.title = [NSString stringWithFormat:@"%lu/%ld",index+1,_questions.count];
     if (index == NSNotFound) {
     return nil;
     }
     
     index++;
     
     if (index == [self.questions count]) {
     return nil;
     }
     
     
     return [self viewControllerAtIndex:index];
     }
     
     - (ReviewPageContentVC *)viewControllerAtIndex:(NSInteger)index
     {
     
     if (([self.questions count] == 0) || (index >= [self.questions count])) {
     return nil;
     }
     // Create a new view controller and pass suitable data.
     ReviewPageContentVC *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"review"];
     
     pageContentViewController.pageindex = index;
     pageContentViewController.question = [_questions objectAtIndex:index];
     pageContentViewController.studentAnswer = [_studentAnswers objectAtIndex:index];
     return pageContentViewController;
     }

     */
    
    func pageControllerAt(index : NSInteger)->SalonContentViewController{
        let salonContentVC = SalonContentViewController(nibName: "SalonContentViewController", bundle: nil)
        
        salonContentVC.pageIndex = index
       // salonContentVC.salon = Salon()
        
        return salonContentVC
    }
    
    
    func setupContent(){
        
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
    /*
     NSInteger index = ((ReviewPageContentVC*) viewController).pageindex;
     _currentPageIndex = index;
     self.navigationItem.title = [NSString stringWithFormat:@"%lu/%ld",index+1,_questions.count];
     [self checkTagForQuestion:_questions[index]];
     if ((index == 0) || (index == NSNotFound)) {
     return nil;
     }
     index--;
     
     return [self viewControllerAtIndex:index];
     
     NSInteger index = ((ReviewPageContentVC*) viewController).pageindex;
     _currentPageIndex = index;
     [self checkTagForQuestion:_questions[index]];
     self.navigationItem.title = [NSString stringWithFormat:@"%lu/%ld",index+1,_questions.count];
     if (index == NSNotFound) {
     return nil;
     }
     
     index++;
     
     if (index == [self.questions count]) {
     return nil;
     }
     
     
     return [self viewControllerAtIndex:index];
     */
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! SalonContentViewController).pageIndex
        self.currentPageIndex = index
        if((index == 0)||(index == NSNotFound)){
            return nil
        }
        
        index = index + 1
        
       
        print("countbefore")
        return pageControllerAt(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let pageContent = SalonContentViewController(nibName: "SalonContentViewController", bundle: nil)
        print("countafter")
        return pageContent
    }
}
