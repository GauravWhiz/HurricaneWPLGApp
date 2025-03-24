//
//  HurricaneCell.swift
//  Hurricane
//
//  Created by Swati Verma on 28/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation
import WebKit
protocol HurricaneCellDelegate: AnyObject {
    func contentWebViewWithHeight(_ height: CGFloat)
}

class HurricaneCell: UITableViewCell, WKNavigationDelegate, UIScrollViewDelegate {

    @IBOutlet weak var stormImageView: UIImageView!
    @IBOutlet weak var contentWebView: WKWebView!
    @IBOutlet weak var zoomLabelBackground: UIView!
    @IBOutlet weak var mapBottomLineLabel: UILabel!
    @IBOutlet weak var tapToZoomLabel: UILabel!
    @IBOutlet weak var stormImageScrollView: UIScrollView!

    weak var delegate: HurricaneCellDelegate?
    var imageURL: String = ""

    override func awakeFromNib() {
        self.contentWebView.backgroundColor = UIColor.clear
        self.contentWebView.isOpaque = false
        self.contentWebView.scrollView.isScrollEnabled = false
        self.mapBottomLineLabel.backgroundColor = AppDefaults.colorWithHexValue(Int(kLabelGreenColorDark))
        self.tapToZoomLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 29:12))
        self.contentWebView.navigationDelegate = self

        let minScale = self.stormImageScrollView.frame.size.width / self.stormImageView.frame.size.width
        self.stormImageScrollView.minimumZoomScale = minScale
        self.stormImageScrollView.minimumZoomScale = 1
        self.stormImageScrollView.maximumZoomScale = 3
        self.stormImageScrollView.delegate = self

    }
//    HAPP-449 to Migrate UIWebView To WKWebView.
 // MARK: WKWebView Delegates
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        self.contentWebView.evaluateJavaScript("document.body.offsetHeight", completionHandler: { result, _ in
            if let height = result as? CGFloat {

                webView.scrollView.isScrollEnabled = false
                var frame: CGRect = webView.frame
                webView.frame = frame
                frame = webView.frame
                frame.size.height = 1
                webView.frame = frame
                frame.size.height = height
                webView.frame = frame

                if self.delegate != nil {
                    self.delegate!.contentWebViewWithHeight(height)
                }
            }
        })
    }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {

        }

        override func prepareForReuse() {
            super.prepareForReuse()
            self.imageURL = ""
        }

    // scrollview delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.stormImageView
    }
}
