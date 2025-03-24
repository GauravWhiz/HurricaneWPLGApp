//
//  VideoViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 16/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation
import AVKit

class VideoViewController: UIViewController {
    var videoURL: URL?
    var moviePlayerViewController: AVPlayerViewController?
    var isViewActive = false

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.view.backgroundColor = UIColor.black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isViewActive {
            self.popView()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isViewActive = true
        
        if self.videoURL != nil {
            self.playVideoWithURL(self.videoURL!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func playVideoWithURL(_ videoURL: URL) {
        var error: NSError?
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])} else {
            }
            let player = AVPlayer(url: videoURL as URL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        } catch let error1 as NSError {
            error = error1
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
        }
    }

    func popView() {
        self.navigationController!.popToRootViewController(animated: false)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
