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

class VideoViewController: UIViewController {
    
    @IBOutlet weak var tbvVideo: UITableView!
    @IBOutlet weak var btnHome: UIButton!
    
    var moviePlayer : MPMoviePlayerController!
    
    var videoVariable : Variable<[Video]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.configUI()

        //back to home
        self.configTableView()
        _ = btnHome.rx_tap.subscribeNext {
            self.navigationController?.popViewControllerAnimated(true)
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
        _ = self.videoVariable.asObservable().bindTo(self.tbvVideo.rx_itemsWithCellIdentifier("VideoCell", cellType: VideoCell.self)) {
            row,data,cell in
            cell.lblTitle.text = "\(data.title)"
            LazyImage.showForImageView(cell.imvThumnail, url: self.getVideoId(data.thumnailUrl))
        }
        
        _ = self.tbvVideo.rx_itemSelected.subscribeNext {
            indexPath in
            self.tbvVideo.deselectRowAtIndexPath(indexPath, animated: false)
            let url = self.videoVariable.value[indexPath.row].thumnailUrl
            self.playVideo(url)
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
             NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoViewController.doneButtonClick(_:)), name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
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
        self.videoVariable.value.append(Video.init(title: "Cắt tạo kiểu Side Part | Phong cách Chanyeol (EXO) | Minh Phụng ", thumb: "https://www.youtube.com/watch?v=Q4to0oI2N-A"))
        self.videoVariable.value.append(Video.init(title: "Cắt tạo kiểu Side Swept | Hồ Gia Hùng - HKT Band ", thumb: "https://www.youtube.com/watch?v=VgNELJELfDE"))
        self.videoVariable.value.append(Video.init(title: "Cắt tạo kiểu Side Part | Phong cách TAO (EXO) | Ubin-G ", thumb: "https://www.youtube.com/watch?v=AX2HSXMNAGA"))
        self.videoVariable.value.append(Video.init(title: "Cắt tạo kiểu Undercut Quiff | Phong cách Marco Reus | Hoàng Giang ", thumb: "https://www.youtube.com/watch?v=nHognIn1my8"))
        self.videoVariable.value.append(Video.init(title: " Cắt tạo kiểu Layer | Phong cách Luhan (EXO) | Quang Hưng ", thumb: "https://www.youtube.com/watch?v=AgnFqNt_lfQ"))
    }
    
}
