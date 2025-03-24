//
//  DownloadAppViewController.swift
//  Hurricane
//
//  Created by APPLE on 20/02/23.
//  Copyright © 2023 PNSDigital. All rights reserved.
//

import UIKit

class DownloadAppViewController: UIViewController {

    var dataDict = [String : Any]()
    @IBOutlet weak var appNameLbl: UILabel!
    @IBOutlet weak var appPreviewImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDefaults.setNavigationBarTitle(dataDict["title"] as? String ?? "", self.view)

    }
    override func viewWillAppear(_ animated: Bool) {
        let data : [String : String] = dataDict["data"] as! [String : String]
        self.appNameLbl.text = data["appName"]
        self.title = dataDict["title"] as? String ?? ""
        
        var imageurl:URL?
        
        if let imgURL = data["installPreview"] {
            imageurl = URL(string: imgURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        
        if(imageurl != nil) {
            appPreviewImageView.imageFromUrl(url: imageurl!)
        } else {
            let image = UIImage(named: "AppIcon")
            appPreviewImageView.image = image
        }
        appPreviewImageView.layer.cornerRadius = 7.0
        
    }

    @IBAction func downloadAppButtonAction(_ sender: Any) {
        let data : [String : String] = dataDict["data"] as! [String : String]
        
        let appStoreUrl : String = data["iOSInstallURL"] ?? ""
        if(appStoreUrl != "") {
            if let url = URL(string: appStoreUrl) {
                UIApplication.shared.open(url)
            }
        }
    }
    
}
