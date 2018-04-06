//
//  ViewController.swift
//  AVPlayerDemo
//
//  Created by lichanglai on 2018/4/6.
//  Copyright © 2018年 sankai. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var playOrPause: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    lazy var player: AVPlayer = {
        let playerItem = getPlayItem(url: "http://1252350901.vod2.myqcloud.com/dec6ed7bvodgzp1252350901/b4881f334564972818476257153/ZKZznaHaxmYA.mp4")
        let playerTmp = AVPlayer.init(playerItem: playerItem)
        addObserverToPlayerItem(playerItem: playerItem!)
        return playerTmp
    }()
    private func getPlayItem(url:String) -> AVPlayerItem? {
        let url = URL.init(string: url)
        guard url != nil else {
            print("url error!")
            return nil
        }
        let playerItem = AVPlayerItem.init(url: url!)
        return playerItem
    }
    private func addProgressObserver() {
        let playerItem = player.currentItem
        player.addPeriodicTimeObserver(forInterval: CMTime.init(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0)), queue: DispatchQueue.main) { (time) in
            let current = CMTimeGetSeconds(time)
            let total = CMTimeGetSeconds((playerItem?.duration)!)
            print("当前已经播放\(current)s")
            if current > 0 {
                self.progressView.progress = Float(current/total)
            }
        }
    }
    private func addObserverToPlayerItem(playerItem : AVPlayerItem) {
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
    }
    private func removeObserverFromPlayerItem(playerItem : AVPlayerItem) {
        playerItem.removeObserver(self, forKeyPath: "status")
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let playerItem = object as? AVPlayerItem {
            if keyPath == "status" {
                if let newValue = change?[NSKeyValueChangeKey.newKey] {
                    if let status = newValue as? Int {
                        if status == AVPlayerStatus.readyToPlay.rawValue {
                            let seconds = CMTimeGetSeconds(playerItem.duration)
                            print("正在播放...，视频总长度:\(seconds)")
                        }
                    }
                }
            }else if (keyPath == "loadedTimeRanges") {
                let timeRanges = playerItem.loadedTimeRanges
                let timeRange = timeRanges.first?.timeRangeValue
                let startSeconds = CMTimeGetSeconds((timeRange?.start)!)
                let durationSeconds = CMTimeGetSeconds((timeRange?.duration)!)
                let totalBuffer = startSeconds + durationSeconds
                print("共缓冲：\(totalBuffer)")
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addProgressObserver()
        addNotification()
        player.play()
  
        // Do any additional setup after loading the view, typically from a nib.
    }
    private func setupUI() {
        let playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = container.frame
        container.layer.addSublayer(playerLayer)
    }
    deinit {
        removeObserverFromPlayerItem(playerItem: player.currentItem!)
        removeNotification()
    }
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.playbackFinished(noti:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    @objc private func playbackFinished(noti : Notification) {
        print("playbackFinished")
    }
    private func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    @IBAction func playClick(_ sender: UIButton) {
        if player.rate == 0 {
            sender.setImage(UIImage.init(named: "player_pause"), for: .normal)
            player.play()
        }else {
            sender.setImage(UIImage.init(named: "player_play"), for: .normal)
            player.pause()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
