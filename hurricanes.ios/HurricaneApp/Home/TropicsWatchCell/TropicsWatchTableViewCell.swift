//
//  HurricaneImageCell.swift
//  Hurricane
//
//  Created by Swati Verma on 21/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation
import WebKit
import UIKit

class TropicsWatchTableViewCell: UITableViewCell, WKNavigationDelegate, UIScrollViewDelegate {
    @IBOutlet weak var stormImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentWebView: WKWebView!
    @IBOutlet weak var mapBottomLineLabel: UILabel!
    @IBOutlet weak var tapToZoomLabel: UILabel!
    @IBOutlet weak var zoomLabelBackground: UIView!
    @IBOutlet weak var tropicsImageScrollView: UIScrollView!
    
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
    var blurEffectView:UIVisualEffectView!
    private var webViewHeight:Int! = 0
    var reloadWebviewCell = false
    let tapGesture = UITapGestureRecognizer()
    var delegate:LandingPageViewController!
    
    override func awakeFromNib() {
        
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.7
        blurEffectView.frame = self.contentView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.nameLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 29:23))
        self.nameLabel.backgroundColor = UIColor.clear
        self.nameLabel.textColor = UIColor.white
        
        self.mapBottomLineLabel.backgroundColor = AppDefaults.colorWithHexValue(Int(kLabelGreenColorDark))
        self.tapToZoomLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 29:12))
        
        self.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
        
        self.contentWebView.backgroundColor = UIColor.clear
        self.contentWebView.isOpaque = false
        self.contentWebView.scrollView.isScrollEnabled = false
      
        self.contentWebView.navigationDelegate = self
        
        let minScale = self.tropicsImageScrollView.frame.size.width / self.stormImageView.frame.size.width
        self.tropicsImageScrollView.minimumZoomScale = minScale
        self.tropicsImageScrollView.minimumZoomScale = 1
        self.tropicsImageScrollView.maximumZoomScale = 3
        self.tropicsImageScrollView.delegate = self
        
        self.tapGesture.addTarget(self, action: #selector(cellButtonTropicsWatchedTappedLocal(_:)))
        self.stormImageView.addGestureRecognizer(tapGesture)
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
            self.contentWebView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
                
                        if complete != nil {
                            self.contentWebView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, _) in
                                
                                DispatchQueue.main.async {
                                    
                                    self.contentWebView.heightAnchor.constraint(equalToConstant: height as! CGFloat).isActive = true
                                    self.webViewHeight = (height as! Int)
                                    
                                    if self.reloadWebviewCell == false {
                                        self.reloadWebviewCell = true
                                        guard let tableView = self.superview as? UITableView else {
                                           return // or fatalError() or whatever
                                       }
                                    
                                        tableView.reloadData()
                                    }
                                }
                            })
                            
                        }
                        })
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.blurEffectView.removeFromSuperview()
    }
    
    // scrollview delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.stormImageView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if Int(self.contentWebView.frame.size.height) == self.webViewHeight && self.webViewHeight != 0 {
            self.blurEffectView.removeFromSuperview()
            
          // print("layoutSubviews in \(self.webViewHeight) \(self.nameLabel.text!)")
        } else if self.webViewHeight != 0 {
           // print("layoutSubviews out \(self.webViewHeight) \(self.nameLabel.text!)")
            self.blurEffectView.removeFromSuperview()
        }
        
    }
    
    @objc func cellButtonTropicsWatchedTappedLocal(_ gestureRecognizer: UITapGestureRecognizer) {
        if self.delegate != nil {
            self.delegate.cellButtonTropicsWatchedTapped(gestureRecognizer)
        }
    }
    
}
