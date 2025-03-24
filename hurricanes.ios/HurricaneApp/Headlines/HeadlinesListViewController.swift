//
//  MoreSettingsViewController.swift
//  Hurricane
//
//  Created by APPLE on 02/01/23.
//  Copyright © 2023 PNSDigital. All rights reserved.
//

import UIKit
import MessageUI
import SVGKit

class HeadlinesListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableHeadlinesList: UITableView!
    
    private let StationHeadlinesCellIdentifier = "StationHeadlinesCellIdentifier"
    private let kStationHeadlinesTableViewCell = "StationHeadlinesNewsTableViewCell"
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
        AppDefaults.setNavigationBarTitle("Headlines", self.view)
        
        self.tableHeadlinesList.register(UINib(nibName: kStationHeadlinesTableViewCell, bundle: nil), forCellReuseIdentifier: StationHeadlinesCellIdentifier)
        self.tableHeadlinesList.dataSource = self
        self.tableHeadlinesList.delegate = self
        self.tableHeadlinesList.separatorInset = .zero
        self.tableHeadlinesList.separatorStyle = .none
        self.tableHeadlinesList.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
        
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if DataDownloadManager.sharedInstance.stationHeadlinesArray == nil {
             return 0
         } else {
             if DataDownloadManager.sharedInstance.stationHeadlinesArray.count > 3 {
                 return 3
             } else {
                 return DataDownloadManager.sharedInstance.stationHeadlinesArray.count
             }
         }
    }

    // MARK: - UITableViewDataSource Methods
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (kiPadRatioForVideoDisplay*UIScreen.main.bounds.width) + 60
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
         // station headlines
         let headlinesCell = (tableView.dequeueReusableCell(withIdentifier: StationHeadlinesCellIdentifier)! as! StationHeadlinesNewsTableViewCell)
         headlinesCell.backgroundColor = UIColor.clear
         headlinesCell.backgroundBGView.backgroundColor = UIColor.clear
         
         let object = DataDownloadManager.sharedInstance.stationHeadlinesArray[indexPath.row] as? NSDictionary

         headlinesCell.titleLabel.text = object?["title"] as? String

         let thumbUrlStr = object!["thumbUrl"] as? String
         let thumbnailURL = URL(string: thumbUrlStr!)
         headlinesCell.videoImageView.sd_setImage(with: thumbnailURL)

         let tapGesture = UITapGestureRecognizer()
         tapGesture.addTarget(self, action: #selector(stationHeadlinesCellButtonTapped(_:)))
         headlinesCell.backgroundBGView.addGestureRecognizer(tapGesture)
         return headlinesCell

    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.tableHeadlinesList.deselectRow(at: indexPath, animated: true)

    }
    
    @objc func stationHeadlinesCellButtonTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let currentPoint: CGPoint = gestureRecognizer.location(in: self.tableHeadlinesList)
        let indexPath: IndexPath = self.tableHeadlinesList.indexPathForRow(at: currentPoint)!

        if let stationCell: StationHeadlinesNewsTableViewCell = self.tableHeadlinesList.cellForRow(at: indexPath) as? StationHeadlinesNewsTableViewCell {
            if AppDefaults.checkInternetConnection() {

                UIView.animate(withDuration: 0.038, animations: {() -> Void in
                    stationCell.alpha = 0.5
                }, completion: {(_: Bool) -> Void in
                    stationCell.alpha = 1.0
                    // Put your code which should be executed with a delay here
                    let stationHeadlinesViewController = StationHeadlinesViewController(nibName: "StationHeadlinesViewController", bundle: nil)
                    let liveStreamObject = DataDownloadManager.sharedInstance.stationHeadlinesArray[indexPath.row] as? NSDictionary
                    let newsUrlStr = liveStreamObject!["url"] as? String
                    stationHeadlinesViewController.stationHeadlinesURL = newsUrlStr
                    stationHeadlinesViewController.screenTitle = kStationHeadlines
                    self.navigationController?.navigationBar.isHidden = false
                    
                    self.navigationController?.pushViewController(stationHeadlinesViewController, animated: true)

                    stationCell.titleLabel.textColor =  UIColor.white
                })

            } else {
                self.handleNetworkError(nil, statusCode: NSURLErrorNotConnectedToInternet)
            }
        }
    }
     
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return [.portrait, .portraitUpsideDown]
    }
    
}
