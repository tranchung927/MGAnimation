//
//  ViewController.swift
//  MGAnimation
//
//  Created by Admin on 1/18/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController, VideoExportServiceDelegate {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var animationView: UIView!
    
    var playerViewController: AVPlayerViewController?
    let documentsDirectoryURL : URL = {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! as String
        return  URL(fileURLWithPath: path)
    }()
    
    var localBlankVideoPath: URL {
        get {
            return documentsDirectoryURL.appendingPathComponent("video").appendingPathExtension("mp4")
        }
    }
    
    var videoID = NSUUID().uuidString
    
    var localVideoPath: URL {
        get {
            return documentsDirectoryURL.appendingPathComponent("\(videoID)").appendingPathExtension("mp4")
        }
    }
    
    let videoService = VideoService()
    let videoExportService = VideoExportService()
    let animationService = AnimationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        videoExportService.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createAnimation() {
        if animationView.layer.sublayers != nil {
            for layer in animationView.layer.sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        let layer = animationService.animationLayerFromImages(images: [UIImage(named: "p1")!, UIImage(named: "p2")!, UIImage(named: "l1")!, UIImage(named: "l2")!, UIImage(named: "l3")!], texts: [], frameSize: animationView.bounds.size)
        animationView.layer.addSublayer(layer)
    }
    
    @IBAction func onStartButtonClicked(sender: AnyObject) {
        createAnimation()
    }
    
    @IBAction func onExportButtonClicked(sender: AnyObject) {
        progressView.progress = 0
        
        videoService.makeBlankVideo(blankImage: UIImage(named: "whiteBg")!, videoSize: CGSize(width: 300, height: 200), outputPath: localBlankVideoPath, duration: 15) { () -> Void in
            print("localBlankVideoPath : \(self.localBlankVideoPath)")
            self.exportVideo()
        }
    }
    @IBAction func onPlayButtonClicked(sender: AnyObject) {
        playVideo()
    }
    private func playVideo() {
        let url = self.localVideoPath
        let player = AVPlayer(url: url)
        self.playerViewController = AVPlayerViewController()
        self.playerViewController!.player = player
        self.present(self.playerViewController!, animated: true) {
            self.playerViewController!.player!.play()
        }
    }
    
    private func exportVideo() {
        let input = VideoExportInput()
        videoID = NSUUID().uuidString
        input.videoPath = self.localVideoPath
        
        let asset = AVAsset(url: self.localBlankVideoPath)
        input.videoAsset = asset
        DispatchQueue.main.async {
            input.videoFrame = self.animationView.bounds
            input.range = CMTimeRangeMake(kCMTimeZero, asset.duration)
            input.animationLayer = self.animationService.animationLayerFromImages(images: [ UIImage(named: "p1")!, UIImage(named: "p2")!, UIImage(named: "l1")!, UIImage(named: "l2")!, UIImage(named: "l3")!], texts: [], frameSize: self.animationView.bounds.size, startTime: AVCoreAnimationBeginTimeAtZero)
            
            
            self.videoExportService.exportVideoWithInput(input: input)
        }
    }
    
    func videoExportServiceExportSuccess() {
        print("Success")
        DispatchQueue.main.async {
            self.playVideo()
        }
    }
    
    func videoExportServiceExportFailedWithError(error: NSError) {
        print(error)
    }
    
    func videoExportServiceExportProgress(progress: Float) {
        DispatchQueue.main.async {
            self.progressView.progress = progress
        }
    }
}

