//
//  ImageViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 30/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

let ZOOM_VIEW_TAG: Int = 100
let ZOOM_STEP: Int = 3

protocol ImageViewControllerDelegate: AnyObject {
    func imageViewDidDisplay()
    func imageViewDidClose()
}

class ImageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var mapImageView: UIImageView!
    weak var delegate: ImageViewControllerDelegate?
    @IBOutlet weak var animatedImageView: UIImageView!
    var relativeY: CGFloat = 0.0
    var animationImageViewArray: NSArray?
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    var imageInitialScale: CGFloat = 0.0
    var isDoubledTap: Bool = false
    var selectedImage: UIImageView!
    @IBOutlet weak var closeButton:UIButton!
    var loop_gif: String?
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        
        self.mapImageView.stopAnimating()
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isHidden = false

        self.delegate?.imageViewDidClose()
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        let params = GAIDictionaryBuilder.createEvent(withCategory: kMaps, action: kClosed, label: nil, value: nil).build() as [NSObject: AnyObject]
        tracker.send(params)

        self.navigationController?.popViewController(animated: false)
        
        AppDefaults.showTabbar()

    }
    
    func updateOrientation(orientation: UIInterfaceOrientationMask) {
        if #available(iOS 16, *) {
            DispatchQueue.main.async {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation)) { error in
                    print(error)
                    print(windowScene?.effectiveGeometry ?? "")
                }
                
                self.setNeedsUpdateOfSupportedInterfaceOrientations()
                self.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
            
        }
      }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func loadView() {
        super.loadView()
    
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill")?.withTintColor(UIColor.white,renderingMode: .alwaysOriginal), for: .normal)
        closeButton.backgroundColor = UIColor.clear
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(closeButton)
        
        // set the tag for the image view
        self.mapImageView.tag = ZOOM_VIEW_TAG
        // add gesture recognizers to the image view
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.handleSingleTap(_:)))
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.handleDoubleTap(_:)))
        let twoFingerTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.handleTwoFingerTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        twoFingerTap.numberOfTouchesRequired = 2
        self.mapImageView.addGestureRecognizer(singleTap)
        self.mapImageView.addGestureRecognizer(doubleTap)
        self.mapImageView.addGestureRecognizer(twoFingerTap)
        // calculate minimum scale to perfectly fit image width, and begin at that scale
        let minimumScale: CGFloat = self.imageScrollView.frame.size.width / self.mapImageView.frame.size.width
        print("minimum scale")
        print(minimumScale)
        self.imageScrollView.minimumZoomScale = minimumScale
        self.imageScrollView.zoomScale = minimumScale
        imageInitialScale = minimumScale

        self.navigationController?.navigationBar.isHidden = true

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.animatedImageView.image = self.selectedImage.image

        self.mapImageView.autoresizingMask = ([.flexibleWidth, .flexibleHeight])
        self.mapImageView.contentMode = .scaleAspectFit
        self.mapImageView.backgroundColor = UIColor.clear
      
        self.view.backgroundColor = UIColor(white: 0x000000, alpha: 0.0)
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        let params = GAIDictionaryBuilder.createEvent(withCategory: kMaps, action: kZoomed, label: nil, value: nil).build() as [NSObject: AnyObject]
        tracker.send(params)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated);
        
        self.delegate?.imageViewDidDisplay()
        self.view.frame = UIScreen.main.bounds
        self.mapImageView.frame = UIScreen.main.bounds
        var frame: CGRect = self.animatedImageView.frame
        frame.origin.y = frame.origin.y + self.relativeY
        self.animatedImageView.frame = frame

        var centerImagePoint: CGPoint = self.parent!.view.center
        centerImagePoint.y = centerImagePoint.y - (self.navigationController!.navigationBar.frame.size.height / 2) + AppDefaults.getTopPadding() + kTopPadding/3
        self.animatedImageView.center = self.view.center
        self.view.backgroundColor = UIColor(white: 0x000000, alpha: 0.9)
        self.navigationController!.navigationBar.alpha = 0.1

        self.mapImageView.center = self.animatedImageView.center
        self.mapImageView.image = self.animatedImageView.image
        self.animatedImageView.isHidden = true
        self.mapImageView.center = self.view.center
        
        if self.loop_gif != nil {
            // Usage Example
            self.mapImageView.isHidden = true
            MBProgressHUD.showAdded(to: self.view, animated: true)
            downloadGIF(from: self.loop_gif!) { (downloadedURL) in
                if let downloadedURL = downloadedURL {
                    print("GIF downloaded and saved to: \(downloadedURL.path)")
                    let gifDuration = self.getGifDuration(from: downloadedURL)
                    print(gifDuration)
                    
                    if let gifImage = UIImage.gifImageWithName(downloadedURL.path,gifDuration: gifDuration!) {
                        DispatchQueue.main.async {
                            self.mapImageView.isHidden = false
                            self.mapImageView.image = gifImage
                            //self.zoomInImage()
                            self.zoomInImage(timeToWait: 1.5)
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.mapImageView.isHidden = false
                        self.zoomInImage(timeToWait: 1.5)
                    }
                    print("Failed to download the GIF.")
                }
            }
            
            
        } else if self.animationImageViewArray != nil && self.animationImageViewArray!.count > 0 {
                            var animationImages: [UIImage] = [UIImage]()
                            for imageNameWithPath: Any in self.animationImageViewArray! {
                                let imageUrl = URL(string: imageNameWithPath as! String)
                                var imageData: Data?
                                if imageUrl != nil {
                                    do {
                                        imageData = try Data(contentsOf: imageUrl!)
                                    } catch let error {
                                        print("Error in retrieving image:\(error.localizedDescription)")
                                    }
                                }
                                if imageData != nil {
                                    let img = UIImage(data: imageData!)
                                    if img != nil {
                                        animationImages.append(img!)
                                    }
                                }
                            }
                            self.mapImageView.animationImages = animationImages
                            self.mapImageView.animationDuration = kImagesAnimationDuration * Double(animationImages.count)
                            self.mapImageView.startAnimating()
        } else {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            self.zoomInImage(timeToWait: 1.0)
            MBProgressHUD.hide(for: self.view, animated: true)
            
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.navigationController != nil {// HAPP-535
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
        }
    }

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if toInterfaceOrientation.isLandscape {
            self.navigationController!.isNavigationBarHidden = true
            guard let tracker = GAI.sharedInstance().defaultTracker else { return }
            let params = GAIDictionaryBuilder.createEvent(withCategory: kMaps, action: kRotatedLandscape, label: nil, value: nil).build() as [NSObject: AnyObject]
            tracker.send(params)
        } else {
            guard let tracker = GAI.sharedInstance().defaultTracker else { return }
            let params = GAIDictionaryBuilder.createEvent(withCategory: kMaps, action: kRotatedPortrait, label: nil, value: nil).build() as [NSObject: AnyObject]
            tracker.send(params)
        }
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if self.navigationController != nil {// HAPP-535
            self.navigationController!.isNavigationBarHidden = true
        }
        
      /*  switch UIDevice.current.orientation {
            case .landscapeLeft:
                self.closeButton.isHidden = true
                break
            case .landscapeRight:
                self.closeButton.isHidden = true
                break
            case .portrait:
                self.closeButton.isHidden = false
                break
            case .portraitUpsideDown:
                self.closeButton.isHidden = false
                break
            default:
                print("Default")
            }*/
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.imageScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - AppDefaults.getBottomPadding())

    }
    
    // Called when the device rotates (portrait <-> landscape)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            // Update the scroll view and image view frame when rotating
            //self.adjustImageViewFrame()
            //self.imageScrollView.setZoomScale(self.imageScrollView.zoomScale, animated: false)
            self.zoomInImage(timeToWait: 1.5)
            
        })
    }
    
    // Function to resize the imageView while preserving aspect ratio
        func adjustImageViewFrame() {
            let scrollViewWidth = imageScrollView.bounds.width
            let scrollViewHeight = imageScrollView.bounds.height

            // Aspect ratio of the image
            let aspectRatio = self.mapImageView.image!.size.width / self.mapImageView.image!.size.height

            // Resize image view based on current scroll view size
            var imageViewWidth = scrollViewWidth
            var imageViewHeight = imageViewWidth / aspectRatio

            // If the image height is greater than the scroll view height, adjust accordingly
            if imageViewHeight > scrollViewHeight {
                imageViewHeight = scrollViewHeight
                imageViewWidth = imageViewHeight * aspectRatio
            }

            // Set the image view's frame
            self.mapImageView.frame = CGRect(x: (scrollViewWidth - imageViewWidth) / 2,
                                     y: (scrollViewHeight - imageViewHeight) / 2,
                                     width: imageViewWidth,
                                     height: imageViewHeight)
            
          
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func downloadGIF(from urlString: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        // Get the file name (assuming it's the last path component)
        let fileName = url.lastPathComponent
        
        // Get the file's destination URL in the documents directory
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let destinationURL = documentsURL.appendingPathComponent(fileName)
        
        // Check if the file already exists
        if fileManager.fileExists(atPath: destinationURL.path) {
            print("File already exists at: \(destinationURL.path)")
            // File already exists, return the existing file URL
            completion(destinationURL)
            return
        }

        // Create a URLSession to handle the download
        let session = URLSession.shared

        // Start the download task
        let downloadTask = session.downloadTask(with: url) { (tempURL, response, error) in
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let tempURL = tempURL else {
                print("No file URL received")
                completion(nil)
                return
            }

            // Get the file's data and move it to the desired location
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)

            do {
                // Remove any existing file at the destination path
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                
                // Move the downloaded file from temporary location to the final destination
                try fileManager.moveItem(at: tempURL, to: destinationURL)
                print("GIF downloaded to: \(destinationURL.path)")
                completion(destinationURL)
            } catch {
                print("Error saving file: \(error.localizedDescription)")
                completion(nil)
            }
        }

        downloadTask.resume()
    }
    
    func getGifDuration(from url: URL) -> Double? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(imageSource)
        var totalDuration: Double = 0.0
        
        for index in 0..<frameCount {
            if let frameProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil) as? [CFString: Any],
               let gifProperties = frameProperties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
               let delayTime = gifProperties[kCGImagePropertyGIFDelayTime] as? Double {
                totalDuration += delayTime
            }
        }
        
        return totalDuration
    }


    // MARK: UIScrollViewDelegate methods

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageScrollView.viewWithTag(ZOOM_VIEW_TAG)
    }
    /************************************** NOTE **************************************/
    /* The following delegate method works around a known bug in zoomToRect:animated: */
    /* In the next release after 3.0 this workaround will no longer be necessary      */
    /**********************************************************************************/

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(scale + 0.01, animated: false)
        scrollView.setZoomScale(scale, animated: false)
    }

    // MARK: TapDetectingImageViewDelegate methods

    @objc func handleSingleTap(_ gestureRecognizer: UIGestureRecognizer) {
        // single tap does nothing for now
    }

    @objc func handleDoubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        // double tap zooms in
        var newScale: CGFloat
        if isDoubledTap != true {
            isDoubledTap = true
            newScale = self.imageScrollView.zoomScale * CGFloat(ZOOM_STEP)
        } else {
            isDoubledTap = false
            newScale = self.imageScrollView.zoomScale / CGFloat(ZOOM_STEP)
        }
        
        let locationInImageView = gestureRecognizer.location(in: self.mapImageView)
                print("Tapped at: \(locationInImageView)")
        print(self.mapImageView.center)
        print(gestureRecognizer.view)
        print(gestureRecognizer)
        print(self.imageScrollView.frame.width)
        print(self.mapImageView.frame.width)
        print(self.imageScrollView.contentSize.width)
        
        let centerInWindow = self.mapImageView.superview?.convert(self.mapImageView.center, to: nil)
               print("Center of imageView in window: \(centerInWindow ?? CGPoint.zero)")

        
        let zoomRect: CGRect = self.zoomRectForScale(newScale, withCenter: gestureRecognizer.location(in: gestureRecognizer.view!))
        self.imageScrollView.zoom(to: zoomRect, animated: true)
    }

    @objc func handleTwoFingerTap(_ gestureRecognizer: UIGestureRecognizer) {
        // two-finger tap zooms out
        let newScale: CGFloat = self.imageScrollView.zoomScale / CGFloat(ZOOM_STEP)
        let zoomRect: CGRect = self.zoomRectForScale(newScale, withCenter: gestureRecognizer.location(in: gestureRecognizer.view!))
        self.imageScrollView.zoom(to: zoomRect, animated: true)
    }

    // MARK: Utility methods

    func zoomRectForScale(_ scale: CGFloat, withCenter center: CGPoint) -> CGRect {
        var zoomRect = CGRect()
        // the zoom rect is in the content view's coordinates.
        //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
        //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.height = self.imageScrollView.frame.size.height / scale
        zoomRect.size.width = self.imageScrollView.frame.size.width / scale
        // choose an origin so as to get the right center.
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    // Function to zoom in the image 3x
    private func zoomInImage(timeToWait: Double) {
        //self.imageScrollView.isHidden = true
        self.mapImageView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeToWait) {
            self.imageScrollView.setZoomScale(self.imageScrollView.minimumZoomScale*2.5, animated: false)
            
            // 30% from the left edge of the content
            let offsetX = self.imageScrollView.contentSize.width * 0.3
            // After setting the zoom scale, adjust the content offset to ensure the zoom starts from the specified point
            let newOffsetX = offsetX - self.imageScrollView.bounds.size.width * 0.3
            
            let offsetY = (self.imageScrollView.contentSize.height - self.imageScrollView.bounds.size.height) / 2

            
            self.imageScrollView.setContentOffset(CGPoint(x: newOffsetX, y: offsetY), animated: false)

           // self.imageScrollView.isHidden = false
            self.mapImageView.isHidden = false
        }
        
    }
    
}

extension UIImage {

    // Function to load a GIF from the app's bundle
    static func gifImageWithName(_ name: String, gifDuration: Double) -> UIImage? {
        // Get the path for the GIF image in the bundle
     /*   guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
              let url = URL(string: path) else {
            return nil
        }*/

        // Load the data from the URL
        guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: name)) else {
                    print("Error: Could not load data from GIF file.")
                    return nil
                }

        // Create an image source from the GIF data
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }

        // Extract the frames from the GIF
        let frameCount = CGImageSourceGetCount(imageSource)
        var images = [UIImage]()

        for index in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil) {
                let frameImage = UIImage(cgImage: cgImage)
                images.append(frameImage)
            }
        }

        // Return an animated image
        return UIImage.animatedImage(with: images, duration: gifDuration) // You can adjust the duration
    }
    
    
}
