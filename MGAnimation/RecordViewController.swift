//
//  RecordViewController.swift
//  MGAnimation
//
//  Created by Chung-Sama on 2018/01/19.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVKit

struct Coordinate {
    var col: Int
    var row: Int
    init(col: Int, row: Int) {
        self.col = col
        self.row = row
    }
}
class RecordViewController: UIViewController, VideoExportServiceDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var animationView: UIView!
    
    var gameTimer: Timer = Timer()
    
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
    
    var layers: [[CALayer]] = []
    var indexs: [Coordinate] = []
    var assert = 0
    var index = 0 {
        didSet {
            guard index < assert else { return }
            self.layers[self.indexs[index].row][self.indexs[index].col].backgroundColor = UIColor.red.cgColor
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        videoExportService.delegate = self
        setupTextLayer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTextLayer() {
        let size = CGSize(width: view.bounds.width/50, height: view.bounds.width/50)
//        rootLayer.frame = CGRect(x: 0, y: view.bounds.height/2 - view.bounds.width/2, width: view.bounds.width , height: view.bounds.width)
//        view.layer.addSublayer(rootLayer)
        for row in (0..<50) {
            layers.append([])
            for col in (0..<50) {
                let layer: CALayer = CALayer()
                layer.frame = CGRect(origin: CGPoint(x: CGFloat(col) * size.width, y: CGFloat(row) * size.height), size: size)
                layer.backgroundColor = UIColor.blue.cgColor
                animationView.layer.addSublayer(layer)
                layers[row].append(layer)
                indexs.append(Coordinate(col: col, row: row))
            }
        }
        assert = (layers.count * layers[0].count)
    }
    @IBAction func startDraw(_ sender: UIBarButtonItem) {
        index = 0
        gameTimer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(repeatImage), userInfo: nil, repeats: true)
    }
    
    @IBAction func onExport(sender: UIBarButtonItem) {
        progressView.progress = 0
        
        videoService.makeBlankVideo(blankImage: UIImage(named: "whiteBg")!, videoSize: CGSize(width: animationView.bounds.width, height: animationView.bounds.height), outputPath: localBlankVideoPath, duration: 15) { () -> Void in
            print("localBlankVideoPath : \(self.localBlankVideoPath)")
            self.exportVideo()
        }
    }
    @objc func repeatImage() {
        index += 1
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
            input.animationLayer = self.animationView.layer
            
            
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
