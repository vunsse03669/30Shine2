//
//  VideoViewController.swift
//  30Shine
//
//  Created by Mr.Vu on 7/21/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import MediaPlayer
import youtube_parser
import Alamofire
import ReachabilitySwift

class VideoViewController: UIViewController, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var tbvVideo: UITableView!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    
    var moviePlayer : MPMoviePlayerController!
    var videoVariable : Variable<[YoutubeVideo]> = Variable([])
    var reachability : Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.configUI()
        self.tbvVideo.delegate = self

        //back to home
        self.configTableView()
        _ = btnHome.rx_tap
            .subscribeNext {
                //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                self.navigationController?.pop()
        }
        //Click btnProfile
        _ = btnProfile.rx_tap.subscribeNext {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
            self.navigationController?.push(vc, animated: true)
        }
    }
    
    //MARK: UI
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
    }
    
    //MARK: TableView
    func configTableView() {
        _ = self.videoVariable.asObservable()
            .bindTo(self.tbvVideo.rx_itemsWithCellIdentifier("VideoCell", cellType: VideoCell.self)) {
            row,data,cell in
            cell.lblTitle.text = "\(data.title)"
            cell.lblViewCount.text = "\(data.viewCount) views"
            cell.lblTime.text = "• \(cell.caculateTime(data.publishDate))"
            LazyImage.showForImageView(cell.imvThumnail, url: data.thumb)
        }
        
        _ = self.tbvVideo.rx_itemSelected.subscribeNext {
            indexPath in
            self.tbvVideo.deselectRowAtIndexPath(indexPath, animated: false)
            let url = self.videoVariable.value[indexPath.row].link
            let urlPlay = self.getVideo(url)
            self.playVideo(urlPlay)
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
            //self.moviePlayer.stop()
            print(youtubeURL)
             self.playVideoWithYoutubeURL(youtubeURL)
             NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoViewController.doneButtonClick(_:)), name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
        }
    }
    
    func playVideoWithYoutubeURL(url: NSURL) {
        Youtube.h264videosWithYoutubeURL(url, completion: { (videoInfo, error) -> Void in
            if let
                videoURLString = videoInfo?["url"] as? String {
                self.moviePlayer.contentURL = NSURL(string: videoURLString)
            }
        })
    }
    
    func getVideo(url : String) -> String {
        let mask = "watch/"
        let newMask = "watch?v="
        return url.stringByReplacingOccurrencesOfString(mask, withString: newMask)
    }
    
    func doneButtonClick(sender:NSNotification?){
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
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


    //MARK:Dump data
    func initData() {
        
        do {
            reachability = try! Reachability.reachabilityForInternetConnection()
        }
        reachability!.whenReachable = {
            reachability in
            dispatch_async(dispatch_get_main_queue()) {
                self.videoVariable.value = []
                self.parseJson {
                    () in
                    self.videoVariable.value.sortInPlace {
                        return ($0).publishDate > ($1).publishDate
                    }
                }

            }
        }
        reachability!.whenUnreachable = {
            reachability in
            dispatch_async(dispatch_get_main_queue()) {
                let message = "Hiện tại thiết bị của bạn đang không được kết nối internet. Quý khách muốn dùng chức năng này xin vui lòng kiểm tra lại kết nối internet!"
                let alert = UIAlertView(title: "", message: message, delegate: self, cancelButtonTitle: "Xác nhận")
                alert.show()
            }
        }
        try! reachability?.startNotifier()
        
    }
    
    func parseJson(complete: ()->()) {
        /*
         {
         SalonId: 3
         }
         */
        let parameter = ["SalonId": 3]
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            Alamofire.request(.POST,VIDEO_YOUTUBE_API,parameters: parameter, encoding: .JSON)
                .responseJASON { response in
                    if let json = response.result.value {
                        let videos = json["d"].map(YoutubeNetwork.init)
                        for video in videos {
                            if YoutubeVideo.getVideoById(video.id) == nil {
                                let v = YoutubeVideo.create(video.id, title: video.title, link: video.link, thumb: video.thumb, viewCount: video.viewCount,publistDate: video.publishDate)
                                self.videoVariable.value.append(v)
                            }
                            else {
                                self.videoVariable.value.append(YoutubeVideo.getVideoById(video.id))
                            }
                        }
                        complete()
                    }
            }
        }
    }
    
    //MARK: table delegate
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    //MARK: Alertview delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            self.navigationController?.pop()
        }
        
    }
    
}
