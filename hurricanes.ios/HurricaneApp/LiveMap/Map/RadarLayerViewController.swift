//
//  RadarLayerViewController.swift
//  Hurricane
//
//  Created by imac on 14/07/22.
//  Copyright © 2022 PNSDigital. All rights reserved.
//

import UIKit

class RadarLayerViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var bgView: UIView!

    @IBOutlet weak var radarLayerTableView: UITableView!
    var selectedRadarLayer = String()
    var radarLayers = [AnyObject]()
    @IBOutlet weak var tableViewYCordinate: NSLayoutConstraint!
    var tableViewtopMargin = CGFloat()
    override func viewDidLoad() {
        super.viewDidLoad()
        radarLayers = AppDefaults.getRadarLayers()
        // Do any additional setup after loading the view.
        self.radarLayerTableView.delegate = self
        self.radarLayerTableView.dataSource = self
        let HurricaneRadarLayerCellIdentifier = "RadarLayerCellIdentifier"
        self.radarLayerTableView.register(UINib(nibName: kradarLayerCell, bundle: nil), forCellReuseIdentifier: HurricaneRadarLayerCellIdentifier)
        radarLayerTableView.tableFooterView = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        self.bgView.isUserInteractionEnabled = true
        self.bgView.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
        if IS_IPAD {
            let tableViewRequiredHeight: Float = Float(radarLayers.count * 50)
            let viewHeight: Float = Float(self.view.frame.size.height)
            let topSpaceHeight = viewHeight - tableViewRequiredHeight

            self.tableViewYCordinate.constant = CGFloat(topSpaceHeight)
        } else {
            self.tableViewYCordinate.constant = self.tableViewtopMargin
        }
    }

    func closeWindow() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.closeWindow()
    }
    func postLayerNotification(_ layerDict: [String: Any]) {
        var userData: [AnyHashable: Any] = layerDict["map"] as! [AnyHashable: Any]

        if let object = layerDict["title"] {
            userData["title"] = object
            userData["sectionTitle"] = object
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationdidUpdateLayer), object: userData)
        self.closeWindow()
     }
}

extension RadarLayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bgView: UIView = UIView()
        bgView.frame = CGRect(x: 0, y: 0, width: self.radarLayerTableView.frame.size.width, height: 40)
        bgView.backgroundColor = UIColor.clear

       let titleLbl = UILabel()
       titleLbl.frame = CGRect(x: 8, y: 20, width: bgView.frame.size.width, height: 30)
       titleLbl.textColor = UIColor.black
       titleLbl.backgroundColor = UIColor.clear
       titleLbl.font = UIFont.init(name: kHurricaneFont_SemiBold, size: CGFloat(20.0))
       titleLbl.text = "Select View"
       bgView.addSubview(titleLbl)
        return bgView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let radarLayerCellIdentifier: String = "RadarLayerCellIdentifier"
       let cell: RadarLayerCustomCell = (tableView.dequeueReusableCell(withIdentifier: radarLayerCellIdentifier) as! RadarLayerCustomCell)
       cell.titleLbl.text = self.radarLayers[indexPath.row].object(forKey: "title") as? String ?? ""
        if self.selectedRadarLayer == self.radarLayers[indexPath.row].object(forKey: "title") as? String ?? "" {
            cell.statusImage.isHidden = false
        } else {
            cell.statusImage.isHidden = true
        }
       return cell
   }

    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
   }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return radarLayers.count
   }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        postLayerNotification(self.radarLayers[indexPath.row] as! [String: Any])
    }

}
