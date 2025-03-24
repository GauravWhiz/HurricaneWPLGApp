//
//  TodayViewController.swift
//  Hurricane
//
//  Created by Sachin Ahuja on 01/09/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import UIKit
import NotificationCenter

/***************************************  KPRC   ********************************************/
#if (KPRCExtension)
let kAppURL = "PNSDigitalKPRCHurricane://"
let kApplicationGroup = "group.grahamdigital.hurricane.kprc"
    /***************************************  KSAT   ********************************************/
#elseif (KSATExtension)
let kAppURL = "PNSDigitalKSATHurricane://"
let kApplicationGroup = "group.grahamdigital.hurricane.ksat"
    /***************************************  WJXT   ********************************************/
#elseif (WJXTExtension)
let kAppURL = "PNSDigitalWJXTHurricane://"
let kApplicationGroup = "group.grahamdigital.hurricane.wjxt"
    /***************************************  WKMG   ********************************************/
#elseif (WKMGExtension)
let kAppURL = "PNSDigitalWKMGHurricane://"
let kApplicationGroup = "group.grahamdigital.hurricane.wkmg"
    /***************************************  WPLG   ********************************************/
#elseif (WPLGExtension)
let kAppURL = "PNSDigitalWPLGHurricane://"
let kApplicationGroup = "group.grahamdigital.hurricane.wplg"
    /***************************************  Test   ********************************************/
#else
let kAppURL = "PNSDigitalTESTHurricane://"
let kApplicationGroup = "group.GrahamDigital.TestHurricane"
    /***************************************  END   ********************************************/
#endif

let kTitleData = "titleData"
let kCategoryData = "categoryeData"
let kIdData = "idData"
let kMovementData = "movementData"
let kAPIURL = "API_URL"

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var firstLaunchView: UIView!
    @IBOutlet weak var firstLaunchMessage: UILabel!
    @IBOutlet weak var launchAppButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    var titleArray: NSArray?
    var categoryArray: NSArray?
    var idArray: NSArray?
    var movementArray: NSArray?
    var dataURL: String? = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.isOpaque = false
        self.tableView.register(UINib(nibName: "HurricaneWidgetCell", bundle: nil), forCellReuseIdentifier: "HurricaneWidgetCellIdentifier")
        let defaults = UserDefaults(suiteName: kApplicationGroup)
        if defaults != nil {
            if (defaults!.object(forKey: kTitleData)) != nil {
                self.titleArray = defaults!.object(forKey: kTitleData)! as? NSArray
            }
            if (defaults!.object(forKey: kTitleData)) != nil {
                self.titleArray = defaults!.object(forKey: kTitleData)! as? NSArray
            }
            if (defaults!.object(forKey: kCategoryData)) != nil {
                self.categoryArray = defaults!.object(forKey: kCategoryData)! as? NSArray
            }
            if (defaults!.object(forKey: kIdData)) != nil {
                self.idArray = defaults!.object(forKey: kIdData)! as? NSArray
            }
            if (defaults!.object(forKey: kMovementData)) != nil {
                self.movementArray = defaults!.object(forKey: kMovementData)! as? NSArray
            }
            if (defaults!.object(forKey: kAPIURL)) != nil {
                self.dataURL = defaults!.object(forKey: kAPIURL)! as? String
            }
        }
        self.downloadData()
        self.adjustHeightOfTableview()
    }

    override func viewDidLayoutSubviews() {
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.layoutMargins = UIEdgeInsets.zero
    }

    func downloadData() {
        var URL: Foundation.URL?
        if self.dataURL != nil {
            if self.dataURL!.count > 0 {
                self.firstLaunchView.isHidden = true
                self.tableView.isHidden = false
                URL = Foundation.URL(string: self.dataURL!)!
            } else {
                self.invokeLaunchView()
                return
            }
        } else {
            self.invokeLaunchView()
            return
        }

        let task = URLSession.shared.dataTask(with: URL!, completionHandler: { (data, _, error) -> Void in
            print("Task completed")
            if let data = data {
                do {
                    if let dataDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        DispatchQueue.main.async(execute: {
                            let dataArray = (dataDictionary["storms"] as! NSArray)
                            if #available(iOSApplicationExtension 10.0, *) {
                                if dataArray.count > 1 {
                                    self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
                                } else {
                                    self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
                                }
                            }
                            let titleData: NSMutableArray = []
                            let categoryData: NSMutableArray = []
                            let stormId: NSMutableArray = []
                            let movementdataList: NSMutableArray = []
                            for dataDict in dataArray {
                                titleData.add((dataDict as! NSDictionary)["name"]!)
                                categoryData.add((dataDict as! NSDictionary)["category"]!)
                                stormId.add((dataDict as! NSDictionary)["id"]!)
                                let summaryDict = (dataDict as! NSDictionary)["summary"] as! NSDictionary
                                guard let movementData = summaryDict["movement"] else {
                                    movementdataList.add("")
                                    return
                                }

                                let splittedStringsArray = (movementData as! String).split(separator: " ", maxSplits: 1).map(String.init)

                                var movementDataLowercased = ""
                                if splittedStringsArray.count > 0 {
                                    if let firstString = (splittedStringsArray.first) {
                                        movementDataLowercased.append(firstString)
                                        movementDataLowercased.append(" ")
                                    }

                                    if let lastString = (splittedStringsArray.last) {
                                        movementDataLowercased.append(lastString.lowercased())
                                    }
                                }
                                movementdataList.add(movementDataLowercased)
                            }
                            self.titleArray = titleData
                            self.categoryArray = categoryData
                            self.idArray = stormId
                            self.movementArray = movementdataList

                            self.tableView.reloadData()
                            let defaults = UserDefaults(suiteName: kApplicationGroup)
                            defaults!.set(self.titleArray, forKey: kTitleData)
                            defaults!.set(self.categoryArray, forKey: kCategoryData)
                            defaults!.set(self.idArray, forKey: kIdData)
                            defaults!.set(self.movementArray, forKey: kMovementData)
                            defaults!.synchronize()
                            self.adjustHeightOfTableview()
                        })

                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if error != nil {
                self.adjustHeightOfTableview()
            }
        })

        task.resume()
    }

    func invokeLaunchView() {
        self.firstLaunchView.isHidden = false
        self.tableView.isHidden = true
        self.setFirstLaunchText()
        self.adjustHeightOfTableview()
    }

    func setFirstLaunchText() {
        self.firstLaunchMessage.text = "Hurricane App must be opened once before the widget can provide the latest updates on active storms."
        self.launchAppButton.backgroundColor = self.colorWithHexValue(0x747474)
        self.launchAppButton.setTitleColor(UIColor.white, for: UIControl.State())
        self.launchAppButton.layer.borderWidth = 2.0
        self.launchAppButton.layer.cornerRadius = 8.0
        self.launchAppButton.layer.borderColor = UIColor.lightGray.cgColor
    }

    func adjustHeightOfTableview() {
        var height: CGFloat = 90.0; // 50.0;
        if self.titleArray != nil {
            height = max(CGFloat(self.titleArray!.count*90), height)
        }

        // set the height constraint
        self.tableViewHeightConstraint.constant = height
        if self.dataURL == nil {
            self.tableViewHeightConstraint.constant = self.firstLaunchView.frame.size.height
        }
        self.view.needsUpdateConstraints()
    }

    func colorWithHexValue(_ rgbValue: Int) -> UIColor {
        return UIColor(red: (CGFloat((rgbValue & 0xFF0000) >> 16)) / 255.0, green: (CGFloat((rgbValue & 0xFF00) >> 8)) / 255.0, blue: (CGFloat(rgbValue & 0xFF)) / 255.0, alpha: 1.0)
    }

    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            self.adjustHeightOfTableview()
            self.preferredContentSize = CGSize(width: 0.0, height: self.tableViewHeightConstraint.constant)
        } else if activeDisplayMode == .compact {
            self.view.needsUpdateConstraints()
            self.preferredContentSize = maxSize
        }
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.titleArray != nil && self.titleArray!.count > 0 {
            return self.titleArray!.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hurricaneCellIdentifier = "HurricaneWidgetCellIdentifier"
        let cell = (tableView.dequeueReusableCell(withIdentifier: hurricaneCellIdentifier)! as! HurricaneWidgetCell)
        cell.hurricaneCategory.text = ""
        self.configureHurricaneCell(cell, atIndexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? HurricaneWidgetCell {
            cell.backgroundColor = UIColor.clear
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            if cell.backgroundView != nil {
                cell.backgroundView!.backgroundColor = UIColor.clear
            }
            if #available(iOSApplicationExtension 10.0, *) {
                if self.extensionContext?.widgetActiveDisplayMode == .expanded {
                    if (self.titleArray != nil) && (indexPath as NSIndexPath).row < self.titleArray!.count - 1 {
                        if cell.bottomBorder == nil {
                            cell.bottomBorder = CALayer()
                        }
                        cell.bottomBorder!.frame = CGRect(x: 0, y: cell.frame.height - 0.5, width: self.tableView.frame.size.width, height: 0.5)
                        cell.bottomBorder!.backgroundColor = UIColor.gray.cgColor
                        cell.layer.addSublayer(cell.bottomBorder!)
                    } else {
                        cell.bottomBorder?.removeFromSuperlayer()
                    }
                } else {
                    cell.bottomBorder?.removeFromSuperlayer()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.idArray != nil {
            if self.idArray!.count > (indexPath as NSIndexPath).row {
                let stormId = self.idArray![(indexPath as NSIndexPath).row]
                let urlString = "\(kAppURL),?\(stormId)"
                let url = URL(string: urlString)!
                self.extensionContext!.open(url, completionHandler: nil)
            }
        } else {
            let urlString = "\(kAppURL)"
            let url = URL(string: urlString)!
            self.extensionContext!.open(url, completionHandler: nil)
        }
    }

    func configureHurricaneCell(_ cell: HurricaneWidgetCell, atIndexPath indexPath: IndexPath) {
        if self.titleArray == nil || self.titleArray?.count == 0 {
            cell.noDataLabel.text = "No Active Hurricanes"
            cell.noDataLabel.isHidden = false
            cell.hurricaneCategoryBackground.isHidden = true
            cell.hurricaneName.isHidden = true
            cell.noDataLabel.font = UIFont(name: "Helvetica-Oblique", size: 18)

             if #available(iOSApplicationExtension 10.0, *) {
                cell.noDataLabel.textColor = UIColor.black
             } else {
                cell.noDataLabel.textColor = UIColor.white
            }
            return
        }
        if self.titleArray!.count > (indexPath as NSIndexPath).row {
            cell.noDataLabel.isHidden = true
            cell.hurricaneName.isHidden = false
            cell.hurricaneCategoryBackground.isHidden = false
            cell.hurricaneCategory.font = UIFont(name: "Cabin-Bold", size: 22)
            cell.hurricaneCategoryBackground.backgroundColor = UIColor.red
            cell.hurricaneName.text = self.titleArray![(indexPath as NSIndexPath).row] as? String
            if let movementArray = self.movementArray {
            cell.hurricaneMovement.text = movementArray[(indexPath as NSIndexPath).row] as? String
            }

            let category = (self.categoryArray![(indexPath as NSIndexPath).row] as! NSNumber).intValue
            if category != 0 {
                cell.hurricaneCategory.text = "\(Int(category))"
            } else {
                cell.hurricaneCategory.text = "t"
            }
        }
    }

    @IBAction func launchAppButtonTapped(_ sender: Any) {
        let url = URL(string: kAppURL)
        self.extensionContext?.open(url!, completionHandler: nil)
    }
}
