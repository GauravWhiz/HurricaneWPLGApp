//
//  AlertBarViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 29/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

protocol AlertBarDelegate: AnyObject {
    func alertShouldStopDisplay()
}

class AlertBarViewController: UIViewController {
    var notification: Notification?
    var notificationOldID: String?

    var currentNavController:UINavigationController?

    weak var delegate: AlertBarDelegate?
    @IBOutlet weak var alertTextLabel: UILabel!
    @IBOutlet weak var alertButton: UIButton!

    func addGesture() {
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(AlertBarViewController.handleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRecognizer)
    }

    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        self.pushOnNotification()
    }

    func pushOnNotification() {
        self.pushToAlertDetail()
        self.setMetUpdateGANTrackEvent()
    }

    func alertTapped() {
        self.delegate?.alertShouldStopDisplay()
        if self.notification != nil {
            let defaults = UserDefaults.standard
            defaults.set(self.notification?.idx, forKey: kNotificationKey)
            defaults.synchronize()
        }
    }

    func setMetUpdateGANTrackEvent() {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        let params = GAIDictionaryBuilder.createEvent(withCategory: kMetUpdate, action: kClicked, label: self.notification!.idx, value: nil).build() as [NSObject: AnyObject]
        tracker.send(params)
    }

    func pushToAlertDetail() {
        let alertDetailViewController: AlertDetailViewController = AlertDetailViewController(nibName: "AlertDetailViewController", bundle: nil)
        alertDetailViewController.notification = self.notification

        if self.currentNavController != nil {
            self.currentNavController!.pushViewController(alertDetailViewController, animated: false)
        } else {
            self.navigationController!.pushViewController(alertDetailViewController, animated: false)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        var frameSelf: CGRect = self.view.frame
        frameSelf.size.width = UIScreen.main.bounds.size.width
        self.view.frame = frameSelf
        frameSelf = self.alertTextLabel.frame
        frameSelf.size.width = UIScreen.main.bounds.size.width
        self.alertTextLabel.frame = frameSelf
        self.alertTextLabel.font = UIFont(name: kHurricaneFont_Regular, size: 17)
        self.alertTextLabel.backgroundColor = UIColor.clear
        self.alertTextLabel.textColor = UIColor.white
        self.notification = DataDownloadManager.sharedInstance.getNotificationsData()?.last as? Notification
        self.addGesture()
        self.alertTextLabel.text = self.notification?.title
        if self.notificationOldID == self.notification?.idx {
            return
        }
        var frame: CGRect = self.view.frame
        frame.origin = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.origin.y - 33)
        self.view.frame = frame
        UIView.animate(withDuration: Double(kNotificationBarAnimation), delay: 0, options: .transitionFlipFromTop, animations: { [weak self] () -> Void in
                if let strongSelf = self {
                    let origin1: CGPoint = CGPoint(x: strongSelf.view.frame.origin.x, y: strongSelf.view.frame.origin.y + 33)
                    var frame1: CGRect = strongSelf.view.frame
                    frame1.origin = origin1
                    strongSelf.view.frame = frame1
                }
            }, completion: {(_: Bool) -> Void in
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.alertTextLabel.text = self.notification?.title
        self.setAlertBlockPosition()
    }

    func setAlertBlockPosition() {
        let centerOffset = self.alertButton.frame.size.width / 2
        self.alertTextLabel.center = self.view.center
        var centerBlock: CGPoint = self.alertTextLabel.center
        centerBlock.x = centerBlock.x - centerOffset
        self.alertTextLabel.center = centerBlock
        let maxSize: CGSize = CGSize(width: self.alertTextLabel.frame.size.width, height: self.alertTextLabel.frame.size.height)
        var requiredSize: CGSize = self.alertTextLabel.sizeThatFits(maxSize)
        if requiredSize.width > maxSize.width {
            var frame = self.alertTextLabel.frame
            frame.size.width = (frame.size.width + frame.origin.x)-10.0
            frame.origin.x = 5.0
            self.alertTextLabel.frame = frame
            requiredSize = maxSize
        }
        var buttonFrame: CGRect = self.alertButton.frame
        buttonFrame.origin.x = (((self.alertTextLabel.frame.size.width + requiredSize.width) / 2) - centerOffset) + 5
        self.alertButton.frame = buttonFrame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
