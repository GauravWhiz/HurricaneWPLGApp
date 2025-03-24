//
//  LiveStreamViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 15/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

class LiveStreamViewController: UIViewController {

    var liveStream: LiveStream?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.view.backgroundColor = UIColor.clear
        self.setPosition()
        self.addGesture()
    }

    func setPosition() {
        let origin: CGPoint = CGPoint(x: 0.0, y: UIScreen.main.bounds.size.height - self.view.frame.size.height - AppDefaults.getBottomPadding())
        var frame: CGRect = self.view.frame
        frame.origin = origin
        frame.size.width = UIScreen.main.bounds.size.width
        self.view.frame = frame
        self.view!.setNeedsDisplay()
    }

    func addGesture() {
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LiveStreamViewController.playLiveVideo(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRecognizer)
    }

    @objc func playLiveVideo(_ gestureRecognizer: UIGestureRecognizer) {
        let videoViewController: VideoViewController = VideoViewController(nibName: "VideoViewController", bundle: nil)
        self.navigationController!.pushViewController(videoViewController, animated: false)
        let liveStreamUrl = self.liveStream?.videoURL
        if liveStreamUrl != nil {
            videoViewController.videoURL = URL(string: liveStreamUrl!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setLiveStreamFrameAfterDisplayingAd() {
        let origin: CGPoint = CGPoint(x: 0.0, y: UIScreen.main.bounds.size.height - self.view.frame.size.height - (CGFloat(kAdMobAdHeight)+AppDefaults.getBottomPadding()))
        var frame: CGRect = self.view.frame
        frame.origin = origin
        self.view.frame = frame
        self.view!.setNeedsDisplay()
    }
}
