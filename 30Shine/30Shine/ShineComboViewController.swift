//
//  ShineComboViewController.swift
//  30Shine
//
//  Created by Đỗ Ngọc Trình on 8/8/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire
import RealmSwift
import MediaPlayer
import youtube_parser
import ReachabilitySwift

class ShineComboViewController: UIViewController {
    
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewShineCombo: UIView!
    
    @IBOutlet weak var srcollView: UIScrollView!
    @IBOutlet weak var clvSteps: UICollectionView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var btnPlayVideo: UIButton!
    @IBOutlet weak var imvThumbnail: UIImageView!
    
    
    var moviePlayer : MPMoviePlayerController!
    var videoUrl : String = ""
    var comboSteps : Variable<[ComboStep]> = Variable([])
    var comboObject : Combo = Combo()
    var reachability : Reachability?
    var isConnectInternet = true
    
    var shineComboView : ShineComboView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = btnBack.rx_tap
            .subscribeNext {
                self.navigationController?.pop()
        }
        
        _ = btnProfile.rx_tap.subscribeNext {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
            self.navigationController?.push(vc, animated: true)
        }
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        
        
        self.setupContent();
        
        var image = UIImage(named: "img-back")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleBackButton))
    }
    
    func handleBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupContent(){
        
        do {
            reachability = try! Reachability.reachabilityForInternetConnection()
        }
        reachability!.whenReachable = {
            reachability in
            self.isConnectInternet = true
            dispatch_async(dispatch_get_main_queue()) {
                self.comboSteps.value = []
                self.parseJsonOtherServices {
                    self.lblDescription.text = self.comboObject.listVideos[0].img_description
                    self.videoUrl = self.comboObject.listVideos[0].url
                    //                    LazyImage.showForImageView(self.imvThumbnail, url: self.getVideoId(self.videoUrl),defaultImage: IMG_DEFAULT)
                    self.showAndDownLoadImage(self.imvThumbnail, url: self.getVideoId(self.videoUrl), imageName: self.getVideoId(self.videoUrl))
                    print("\(self.getVideoId(self.videoUrl))")
                }
            }
        }
        reachability!.whenUnreachable = {
            reachability in
            self.isConnectInternet = false
            dispatch_async(dispatch_get_main_queue()) {
                self.comboSteps.value = []
                self.comboSteps.value = ComboStep.getAllComboStep()
                self.imvThumbnail.image = UIImage(named: "imag-placeholder")
                self.lblDescription.text = ""
            }
        }
        self.setupCollectionView()
        try! reachability?.startNotifier()
    }
    
    func setupCollectionView(){
        //register nib
        self.clvSteps.registerNib(UINib.init(nibName: "ComboCell", bundle: nil), forCellWithReuseIdentifier: "ComboCell")
        
        //config layout
        let flowLayout: UICollectionViewFlowLayout! = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        let width = self.view.frame.width/2 - 12
        let height = width*454/808
        flowLayout.itemSize = CGSizeMake(width, height)
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        self.clvSteps.setCollectionViewLayout(flowLayout, animated: false)
        
        //datasource
        dispatch_async(dispatch_get_main_queue()){
            _ = self.comboSteps.asObservable().bindTo(self.clvSteps.rx_itemsWithCellIdentifier("ComboCell", cellType: ComboCell.self)){
                row, data, cell in
                cell.lblTitle.text = ""
                //                LazyImage.showForImageView(cell.imvBackground, url: data.thumb,defaultImage: IMG_DEFAULT)
                self.showAndDownLoadImage(cell.imvBackground, url: data.thumb, imageName: data.thumb)
            }
        }
        
        print("\n\n\n\n------------\(self.imvThumbnail.frame.height) \(self.lblDescription.frame.height)+\(self.clvSteps.frame.height) \(self.srcollView.frame.height)")
    }
    
    func parseJsonOtherServices(complete:()->()){
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let parameter = ["Id": 2]
            Alamofire.request(.POST, SHINE_COMBO_API,parameters: parameter,encoding: .JSON).responseJASON { response in
                if let json = response.result.value {
                    
                    let combo = ComboNetwork.init(json["d"])
                    let listComboSteps : List<ComboStep> = List<ComboStep>()
                    let listVideos : List<VideoObject> = List<VideoObject>()
                    
                    //get list step
                    for comboStep in combo.combosteps{
                        let newStep = ComboStep.create(comboStep.url, thumb: comboStep.thumb, title: comboStep.title, img_description: comboStep.img_description)
                        self.comboSteps.value.append(newStep)
                        listComboSteps.append(newStep)
                    }
                    //get list video
                    for video in combo.videos{
                        let newVideoObject = VideoObject.create(video.url, thumb: video.thumb, title: video.title, img_description: video.img_description)
                        listVideos.append(newVideoObject)
                    }
                    
                    let comboObject:Combo = Combo.create(combo.ID, name: combo.name, listSteps: listComboSteps, listVideos: listVideos)
                    self.comboObject = comboObject
                    
                    complete()
                }
            }
        }
    }
    
    @IBAction func btnPlayDidTap(sender: AnyObject) {
        if(!videoUrl.isEmpty){
            playVideo(videoUrl)
        }
    }
    
    //MARK: Youtube
    func getVideoId(url : String) -> String {
        var str = ""
        let urlStr = "http://img.youtube.com/vi/MASK_ID/0.jpg"
        for c in url.characters {
            str.append(c)
            if c == "=" {
                break
            }
        }
        let id = url.stringByReplacingOccurrencesOfString(str, withString: "")
        return urlStr.stringByReplacingOccurrencesOfString("MASK_ID", withString: id)
    }
    
    func playVideo(url : String) {
        self.moviePlayer = MPMoviePlayerController()
        
        self.view.layoutIfNeeded()
        self.moviePlayer.view.frame = self.view.frame
        self.moviePlayer.view.center = self.view.center
        self.view.addSubview(self.moviePlayer.view)
        self.moviePlayer.fullscreen = true
        let youtubeURL = NSURL(string: url)!
        if youtubeURL.absoluteString != "" {
            self.moviePlayer.stop()
            self.playVideoWithYoutubeURL(youtubeURL)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.doneButtonClick(_:)), name: MPMoviePlayerDidExitFullscreenNotification, object: nil)
        }
    }
    
    func playVideoWithYoutubeURL(url: NSURL) {
        Youtube.h264videosWithYoutubeURL(url, completion: { (videoInfo, error) -> Void in
            if let
                videoURLString = videoInfo?["url"] as? String,
                _ = videoInfo?["title"] as? String {
                self.moviePlayer.contentURL = NSURL(string: videoURLString)
            }
        })
    }
    
    func doneButtonClick(sender:NSNotification?){
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerDidExitFullscreenNotification, object: nil)
        self.moviePlayer.stop()
        UIView.animateWithDuration(0.3, animations: {
            self.moviePlayer.stop()
            self.moviePlayer.view.alpha = 0
        }) { (animate) in
            self.moviePlayer.stop()
            self.moviePlayer.view.removeFromSuperview()
            self.moviePlayer = nil
        }
    }
}

extension ShineComboViewController {
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
    
    func showAndDownLoadImage(imageView : UIImageView, url: String, imageName: String) {
        if self.isConnectInternet {
            LazyImage.showForImageView(imageView, url: url, defaultImage: IMG_DEFAULT, completion: {
                let newName = imageName.stringByReplacingOccurrencesOfString("/", withString: "")
                if let dataa = UIImageJPEGRepresentation(imageView.image!, 0.8) {
                    let filename = self.getDocumentsDirectory().stringByAppendingPathComponent(newName)
                    dataa.writeToFile(filename, atomically: true)
                    print(filename)
                }
            })
        }
        else {
            imageView.image = UIImage(contentsOfFile: self.getImagePathFromDisk(imageName))
            print(imageName)
        }
    }
    
    
}
