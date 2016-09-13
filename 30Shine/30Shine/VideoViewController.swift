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
import SVProgressHUD
import XCDYouTubeKit

class VideoViewController: UIViewController, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var tbvVideo: UITableView!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    
    var videoVariable : Variable<[YoutubeVideo]> = Variable([])
    var videoPlayerViewController : XCDYouTubeVideoPlayerViewController!
    var reachability : Reachability?
    var time : NSTimer!
    
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
                self.navigationController?.popViewControllerAnimated(true)
        }
        self.addRightButton {
            if self.isLogin() {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SelectProfileController") as! SelectProfileController
                self.navigationController?.push(vc, animated: true)
            }
            else {
                self.showAlert("Bạn chưa đăng nhập", message: "Mời quý khách đăng nhập/đăng ký tài khoản để sử dụng đầy đủ chức năng của ứng dụng!")
            }
        }
        
    }
    
    //MARK: UI
    func configUI() {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.frame = CGRectMake(0, 0, 64, 40)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        
        //Activity indicator
        SVProgressHUD.showWithStatus("Đang tải dữ liệu")
    }
    
    //MARK: TableView
    func configTableView() {
        _ = self.videoVariable.asObservable()
            .bindTo(self.tbvVideo.rx_itemsWithCellIdentifier("VideoCell", cellType: VideoCell.self)) {
            row,data,cell in
            cell.lblTitle.text = "\(data.title)"
            cell.lblViewCount.text = "\(data.viewCount) views"
            cell.lblTime.text = "• \(cell.caculateTime(data.publishDate))"
            if data.isSeen {
                 cell.lblNote.hidden = true
            }
            else {
                cell.lblNote.hidden = false
            }
            LazyImage.showForImageView(cell.imvThumnail, url: data.thumb)
        }
        
        _ = self.tbvVideo.rx_itemSelected.subscribeNext {
            indexPath in
            self.tbvVideo.deselectRowAtIndexPath(indexPath, animated: false)
            let videoId = self.videoVariable.value[indexPath.row].videoId
            YoutubeVideo.hadSeen(self.videoVariable.value[indexPath.row])
            self.tbvVideo.reloadData()
            self.playVideo(videoId)
        }
    }
    
    func playVideo(videoId : String) {
        if videoId != "" {
            self.btnHome.userInteractionEnabled = false
            self.btnHome.hidden = true
            videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoId)
            videoPlayerViewController.presentInView(self.view)
            videoPlayerViewController.moviePlayer.prepareToPlay()
            videoPlayerViewController.moviePlayer.play()
            do{
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch {
                //Didn't work
            }
            
            if videoPlayerViewController.moviePlayer.playbackState != .Playing {
                 time = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: #selector(playVideoFullScreen), userInfo: nil, repeats: true)
            }
            
        }
    }
    
    func playVideoFullScreen() {
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoViewController.doneButtonClick(_:)), name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
        if videoPlayerViewController.moviePlayer.playbackState == .Playing {
            videoPlayerViewController.moviePlayer.fullscreen = true
            time.invalidate()
            self.btnHome.userInteractionEnabled = true
            self.btnHome.hidden = false
        }
    }
    
    func getVideo(url : String) -> String {
        let mask = "watch/"
        let newMask = "watch?v="
        return url.stringByReplacingOccurrencesOfString(mask, withString: newMask)
    }
    
    func doneButtonClick(sender:NSNotification?){
        
        self.videoPlayerViewController.view.removeFromSuperview()
        self.videoPlayerViewController.moviePlayer.stop()
        self.videoPlayerViewController = nil
        
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
        print("ccc")
//        UIView.animateWithDuration(0.3, animations: {
//            }) { (animate) in
//                self.videoPlayerViewController.view.removeFromSuperview()
//                self.videoPlayerViewController.moviePlayer.stop()
//                self.videoPlayerViewController = nil
//        }
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
                    dispatch_async(dispatch_get_main_queue(), { 
                        SVProgressHUD.popActivity()
                    })
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
        let parameter = ["SalonId": 3]
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            Alamofire.request(.POST,VIDEO_YOUTUBE_API,parameters: parameter, encoding: .JSON)
                .responseJASON { response in
                    if let json = response.result.value {
                        let videos = json["d"].map(YoutubeNetwork.init)
                        for video in videos {
                            if YoutubeVideo.getVideoById(video.id) == nil {
                                let v = YoutubeVideo.create(video.id, title: video.title, link: video.link, thumb: video.thumb, viewCount: video.viewCount,publistDate: video.publishDate, videoId: video.videoId)
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
            self.navigationController?.popViewControllerAnimated(true)
        }
        if buttonIndex == 1 {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginController") as! LoginController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func showAlert(title : String, message : String) {
        let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "Để sau", otherButtonTitles: "Đăng nhập")
        alert.show()
    }
}
