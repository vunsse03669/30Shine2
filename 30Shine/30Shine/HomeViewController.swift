//
//  HomeViewController.swift
//  30Shine
//
//  Created by Mr.Vu on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import Spring
import ReachabilitySwift

class HomeViewController: UIViewController {
    
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var clvMenu: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imvSlide: SpringImageView!
    var reachability : Reachability?
    var isConnectInternet = true
    
    var currentPage = 0
    let swipeGestureLeft = UISwipeGestureRecognizer()
    let swipeGestureRight = UISwipeGestureRecognizer()
    var isPressOnSlider = false
    
    var slideImageVar : Variable<[String]> = Variable([])
    var menuVariable  : Variable<[Menu]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.configUI()
        self.configSilder()
        //Click btnProfile
        _ = btnProfile.rx_tap.subscribeNext {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SelectProfileController") as! SelectProfileController
            self.navigationController?.push(vc, animated: true)
        }
    }
    //MARK: UI
    func configUI() {
        self.pageControl.userInteractionEnabled = false
        self.imvSlide.userInteractionEnabled = true
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationController?.navigationBar.translucent = false
        self.configColletionLayout()
    }
    
    func configColletionLayout() {
        self.view.layoutIfNeeded()
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 1
        let width = (self.view.frame.width - 25)/2
        layout.itemSize = CGSizeMake(width, 0.7*width)
        self.clvMenu.setCollectionViewLayout(layout, animated: true)
    }
    
    //MARK: CollectioView
    func configCollectionView() {
        dispatch_async(dispatch_get_main_queue()) {
            _ = self.menuVariable.asObservable().bindTo(self.clvMenu.rx_itemsWithCellIdentifier("MenuCell", cellType: MenuCell.self)) {
                row,data,cell in
                if self.isConnectInternet {
                    LazyImage.showForImageView(cell.imvMenu, url: data.imageName, completion: {
                        if let dataa = UIImagePNGRepresentation(cell.imvMenu.image!) {
                            let filename = self.getDocumentsDirectory().stringByAppendingPathComponent("\(data.title).png")
                            dataa.writeToFile(filename, atomically: true)
                            
                        }
                    })

                }
                else {
                    cell.imvMenu.image = UIImage(contentsOfFile: self.getImagePathFromDisk("\(data.title).png"))
                }
            }
        }
        
        _ = self.clvMenu.rx_itemSelected.subscribeNext {
            indexPath in
            
            //trinh
            let selectedCell : MenuCell = self.clvMenu.cellForItemAtIndexPath(indexPath) as! MenuCell
            
            selectedCell.bounceAction({
                var vc : UIViewController!
                switch indexPath.row {
                case 1 :
                    vc = self.storyboard?.instantiateViewControllerWithIdentifier("HairCollectionViewController") as? HairCollectionViewController
                case 2 :
                    vc = self.storyboard?.instantiateViewControllerWithIdentifier("BookingViewController") as? BookingViewController
                    
                case 3:
                    vc = self.storyboard?.instantiateViewControllerWithIdentifier("VideoViewController") as? VideoViewController
                case 4:
//                    if let url = NSURL(string: PRODUCT_LINK) {
//                        UIApplication.sharedApplication().openURL(url)
//                    }
                     vc = self.storyboard?.instantiateViewControllerWithIdentifier("CosmeticViewController") as? CosmeticViewController
                case 5:
                    vc = self.storyboard?.instantiateViewControllerWithIdentifier("ListSalonsViewController") as? ListSalonsViewController
                   // vc = ListSalonsViewController(nibName: "ListSalonsViewController", bundle: nil)
                //SalonsViewController(nibName: "SalonsViewController", bundle: nil)//self.storyboard?.instantiateViewControllerWithIdentifier("ChainSystemViewController") as? ChainSystemViewController
                    
                case 6:
                    vc = self.storyboard?.instantiateViewControllerWithIdentifier("ServicesViewController") as? ServicesViewController
                default:
                    print("Tap Failed!!!")
                }
                if vc != nil {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
    }
    
    //MARK: Silder banner
    func configSilder() {
        self.swipeGestureLeft.direction  = UISwipeGestureRecognizerDirection.Left
        self.swipeGestureRight.direction = UISwipeGestureRecognizerDirection.Right
        self.imvSlide.addGestureRecognizer(self.swipeGestureLeft)
        self.imvSlide.addGestureRecognizer(self.swipeGestureRight)
        self.swipeGestureRight.addTarget(self, action: #selector(HomeViewController.handleSwipeRight(_:)))
        self.swipeGestureLeft.addTarget(self, action: #selector(HomeViewController.handleSwipeLeft(_:)))
        
        let longPress = UILongPressGestureRecognizer.init()
        _ = longPress.rx_event.subscribeNext {
            gestureReconizer in
            if gestureReconizer.state == UIGestureRecognizerState.Began {
                self.isPressOnSlider = true
            }
            else if gestureReconizer.state == UIGestureRecognizerState.Ended {
                self.isPressOnSlider = false
            }
        }
        self.imvSlide.addGestureRecognizer(longPress)
        
        self.chageImageForSlider()
        NSTimer.scheduledTimerWithTimeInterval(SLIDER_SCHEDULE, target: self, selector: #selector(self.autoNextSlide), userInfo: nil, repeats: true)
        
    }
    
    func chageImageForSlider() {
        _ = self.slideImageVar.asObservable().subscribeNext {
            slides in
            self.pageControl.numberOfPages = slides.count
            if slides.count > 0 {
                self.imvSlide.fadeIn(0.8)
                LazyImage.showForImageView(self.imvSlide, url: slides[self.pageControl.currentPage])
            }
        }
    }
    
    func handleSwipeRight(gesture: UISwipeGestureRecognizer) {
        self.pageControl.currentPage -= 1
        self.currentPage -= 1
        if self.currentPage < 0 {
            self.pageControl.currentPage = 0
            self.currentPage = 0
        }
        self.chageImageForSlider()
    }
    
    func handleSwipeLeft(gesture: UISwipeGestureRecognizer) {
        self.pageControl.currentPage += 1
        self.currentPage += 1
        if self.currentPage == self.pageControl.numberOfPages {
            self.pageControl.currentPage = self.pageControl.numberOfPages - 1
            self.currentPage = self.pageControl.numberOfPages - 1
        }
        self.chageImageForSlider()
    }
    
    func autoNextSlide() {
        if !self.isPressOnSlider {
            self.pageControl.currentPage += 1
            self.currentPage += 1
            if self.currentPage == self.pageControl.numberOfPages {
                self.pageControl.currentPage = 0
                self.currentPage = 0
            }
            self.chageImageForSlider()
        }
    }
    
    //MARK: Data
    func initData() {
        do {
            reachability = try! Reachability.reachabilityForInternetConnection()
        }
        reachability!.whenReachable = {
            reachability in
            self.isConnectInternet = true
            dispatch_async(dispatch_get_main_queue()) {
                self.menuVariable.value = []
                self.slideImageVar.value = []
                self.parseJsonMenu({() in
                })
                self.parseJsonSlide()
            }
        }
        reachability!.whenUnreachable = {
            reachability in
            self.isConnectInternet = false
            dispatch_async(dispatch_get_main_queue()) {
                self.menuVariable.value = []
                self.menuVariable.value = Menu.getAllMenu()
            }
        }
        self.configCollectionView()
        try! reachability?.startNotifier()
    }
    
    func parseJsonMenu(complete:()->()) {
        let parameter = ["Id":1000]
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            Alamofire.request(.POST, MENU_API,parameters: parameter,encoding: .JSON).responseJASON { response in
                if let json = response.result.value {
                    let menus = json["d"].map(MenuNetwork.init)
                    for menu in menus {
                        if Menu.getMenuByTitle(menu.name) == nil {
                            self.menuVariable.value.append(Menu.create(menu.name, imageName: menu.thumb.imageUrl))
                        }
                        else {
                            self.menuVariable.value.append(Menu.getMenuByTitle(menu.name))
                        }
                    }
                    complete()
                }
            }
        }
    }
    
    func parseJsonSlide() {
        let parameter = ["Id":1000]
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            Alamofire.request(.POST, SLIDE_HOME_API,parameters: parameter,encoding: .JSON).responseJASON { response in
                if let json = response.result.value {
                    let slides = json["d"].map(SlideNetwork.init)
                    for slide in slides {
                        self.slideImageVar.value.append(slide.image.imageUrl)
                    }
                }
            }
        }
        
    }
    
}

//MARK: Save Image To document
extension HomeViewController {
    func getImagePathFromDisk(name : String) -> String {
        let newName = name.stringByReplacingOccurrencesOfString("/", withString: "")
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let getImagePath = paths.stringByAppendingString("/\(newName)")
        //self.imv.image = UIImage(contentsOfFile: getImagePath)
        return getImagePath
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
 
}
