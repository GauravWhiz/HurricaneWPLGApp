//
//  MoreSettingsViewController.swift
//  Hurricane
//
//  Created by APPLE on 02/01/23.
//  Copyright © 2023 PNSDigital. All rights reserved.
//52,85,129
let tableBackgroundColor = UIColor.init(ciColor: CIColor(red: 52/255.0, green: 85/255.0, blue: 129/255.0))
let tableHeaderViewBackgroundColor =  UIColor.init(ciColor: CIColor(red: 38/255.0, green: 59/255.0, blue: 90/255.0))
let tableHeaderViewBorderColor = UIColor.init(ciColor: CIColor(red: 217/255.0, green: 130/255.0, blue: 36/255.0))
let tableSelectedCellBackgroundColor =  UIColor(red: 86/255, green: 126/255, blue: 173/255, alpha: 1)
protocol SettingsProtocol {
    func OpenSettings(configData : [String:Any], selectedIndex: IndexPath)
}

import UIKit
import MessageUI

class MoreSettingsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var table: UITableView!
    @IBOutlet var blurView: UIView!
    var snapShotView:UIView!
    
    var settingsProtocolObj : SettingsProtocol?
    let kCellColor = 0x143146
    let kSettingsHeaderLabelFontSize = (IS_IPAD ? 25 : 23)
    let kSettingsRowTextFontSize = (IS_IPAD ? 25 : 23)
    var moreSettingsArray = [Any]()
    var selectedIndex = IndexPath()
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.moreSettingsArray = AppDefaults.getMoreSettingConfig()
        self.table.dataSource = self
        self.table.delegate = self
        self.table.separatorInset = .zero
        self.table.backgroundColor = tableBackgroundColor
        self.table.tableFooterView = UIView()
        self.table.bounces = false
        if #available(iOS 15.0, *) {
            self.table.sectionHeaderTopPadding = 0
        }
        
    }
    override func viewDidLayoutSubviews() {
        let tableFrameYPosition =  self.view.frame.size.height - CGFloat(self.moreSettingsArray.count * 60 + 60)
        var tableFrame = self.table.frame
        if(tableFrame.height > (self.view.frame.height + 60)) {
            tableFrame = self.view.frame
            tableFrame.origin.y = 65
            tableFrame.size.height = tableFrame.size.height - 60
            self.table.bounces = true
            self.table.frame = tableFrame
        } else {
            tableFrame.origin.y = tableFrameYPosition
            self.table.frame = tableFrame
        }
       
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        view.backgroundColor = tableHeaderViewBackgroundColor
        view.addBorder(toSide: .Top, withColor: tableHeaderViewBorderColor.cgColor, andThickness: 8)
        
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 20, width: view.frame.width - 20, height: 30))

        titleLabel.font = UIFont(name: kHurricaneFont_Bold, size: CGFloat(kSettingsHeaderLabelFontSize))

        titleLabel.text = "More"
        titleLabel.textColor = .white
        view.addSubview(titleLabel)
        
        return view
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.moreSettingsArray.count
    }

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier: String = "Cell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
         let config : [String : Any] = self.moreSettingsArray[indexPath.row] as! [String : Any]
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
            cell!.selectionStyle = .none
            cell!.textLabel?.textColor = UIColor.white
            cell!.textLabel?.font = UIFont(name: kHurricaneFont_Medium, size: CGFloat(kSettingsRowTextFontSize))
            
            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            imgView.image = UIImage(named: "rightArrow.png")!
            imgView.sizeToFit()
        
        }
         
        if(moreSettingsSelectedIndexPath.count != 0) {
             if (moreSettingsSelectedIndexPath == indexPath) {
                 cell!.backgroundColor = tableSelectedCellBackgroundColor
             } else {
                 cell!.backgroundColor = UIColor.clear
             }
         } else {
             cell!.backgroundColor = UIColor.clear
         }
         cell!.textLabel!.text = config["title"] as? String ?? ""

        return cell!
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         self.table.deselectRow(at: indexPath, animated: true)
         let config : [String : Any] = self.moreSettingsArray[indexPath.row] as! [String : Any]
         //For back button in navigation bar
            let backButton = UIBarButtonItem()
            backButton.title = ""
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
             self.settingsProtocolObj?.OpenSettings(configData: config, selectedIndex: indexPath)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return [.portrait, .portraitUpsideDown]
    }
}
