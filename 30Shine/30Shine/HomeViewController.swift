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

class HomeViewController: UIViewController {

    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var clvMenu: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
   
    @IBOutlet weak var imvSlide: SpringImageView!
    
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
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
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
        
        self.configColletionLayout()
    }
    
    func configColletionLayout() {
        self.view.layoutIfNeeded()
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let width = (self.view.frame.width - 25)/2 
        layout.itemSize = CGSizeMake(width, 1.1*width)
        self.clvMenu.setCollectionViewLayout(layout, animated: true)
    }
    
    //MARK: CollectioView
    func configCollectionView() {
        dispatch_async(dispatch_get_main_queue()) {
            _ = self.menuVariable.asObservable().bindTo(self.clvMenu.rx_itemsWithCellIdentifier("MenuCell", cellType: MenuCell.self)) {
                row,data,cell in
                LazyImage.showForImageView(cell.imvMenu, url: data.imageName)
                cell.lblTitle.text = "\(data.title)"
            }
        }
        
        _ = self.clvMenu.rx_itemSelected.subscribeNext {
            indexPath in
            var vc : UIViewController!
            switch indexPath.row {
            case 1 :
                vc = self.storyboard?.instantiateViewControllerWithIdentifier("HairCollectionViewController") as? HairCollectionViewController
            case 2 :
                vc = self.storyboard?.instantiateViewControllerWithIdentifier("BookingViewController") as? BookingViewController

            case 3:
                vc = self.storyboard?.instantiateViewControllerWithIdentifier("VideoViewController") as? VideoViewController
            case 5:
                
                vc = self.storyboard?.instantiateViewControllerWithIdentifier("ChainSystemViewController") as? ChainSystemViewController
            default:
                print("Tap Failed!!!")
            }
            if vc != nil {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
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
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(self.autoNextSlide), userInfo: nil, repeats: true)

    }
    
    func chageImageForSlider() {
        _ = self.slideImageVar.asObservable().subscribeNext {
            slides in
            self.pageControl.numberOfPages = slides.count
            if slides.count > 0 {
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
        self.parseJsonMenu({() in
            self.configCollectionView()
        })
        self.parseJsonSlide()
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
