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

class StormsListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, HurricaneImageCellDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var tableStormsList: UITableView!
    
    private let HurricaneImageCellIdentifier = "HurricaneImageCellIdentifier"
    private let kHurricaneImageCell = "HurricaneImageCell"
    private let kCustomerTableViewHeaderView = "CustomerTableViewHeaderView"
    private let CustomerTableViewHeaderView = "CustomerTableViewHeaderView"
    private let headerHeight = (IS_IPAD ?75.0:115)
    
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.managedObjectContext = DataManager.sharedInstance.mainObjectContext

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.takeSnapShotOfView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        self.view.backgroundColor = AppDefaults.colorWithHexValue(kBackgroundColor)
        AppDefaults.setNavigationBarTitle("Currently", self.view)
        
        do {
            try self.getFetchedResultsController().performFetch()
        } catch let error {
            print("Unresolved error in fetching data: \(error.localizedDescription)")
        }
        
        var tableFrame = self.tableStormsList.frame
        tableFrame.origin.y = UIApplication.shared.statusBarHeight + navigationBarHeight
        tableFrame.size.height = tableFrame.size.height - tableFrame.origin.y - (self.tabBarController?.tabBar.frame.size.height ?? 0)
        self.tableStormsList.frame = tableFrame
        
        self.tableStormsList.register(UINib(nibName: kHurricaneImageCell, bundle: nil), forCellReuseIdentifier: HurricaneImageCellIdentifier)
        self.tableStormsList.register(UINib(nibName: kCustomerTableViewHeaderView, bundle: nil),forHeaderFooterViewReuseIdentifier: CustomerTableViewHeaderView)
        self.tableStormsList.dataSource = self
        self.tableStormsList.delegate = self
        self.tableStormsList.separatorInset = .zero
        self.tableStormsList.separatorStyle = .none
        self.tableStormsList.backgroundColor = AppDefaults.colorWithHexValue(kBackgroundColor)
        self.tableStormsList.tableHeaderView = nil
        self.tableStormsList.tableFooterView = nil
        
        if #available(iOS 15.0, *) {
            self.tableStormsList.sectionHeaderTopPadding = 0
        }
    }
    
    // MARK: - fetchedResultsController

    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        if fetchedResultsController != nil {
            return fetchedResultsController
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: kEntityStormCenter, in: managedObjectContext)!
        fetchRequest.entity = entity
        let sort = NSSortDescriptor(key: "stormPriority", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 20
        let theFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "Root")
        self.fetchedResultsController = theFetchedResultsController
        self.fetchedResultsController.delegate = self
        return fetchedResultsController
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
         let noOfObjects = fetchedResultsController.fetchedObjects?.count
     
         if noOfObjects != nil {
             if noOfObjects! > 0 {
                 return noOfObjects!
             } else {
                 return 0
             }
                 
         } else {
             return 0
         }
    }

    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let noOfObjects = fetchedResultsController.sections?[0].numberOfObjects
        var height =  headerHeight
        if noOfObjects != nil {
            
            if noOfObjects! > 0 {
                height = CGFloat.leastNormalMagnitude
            }
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let noOfObjects = fetchedResultsController.sections?[0].numberOfObjects
        
        let noActiveStormsHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kCustomerTableViewHeaderView) as! CustomerTableViewHeaderView
        noActiveStormsHeaderView.contentView.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
        noActiveStormsHeaderView.labelTitle.font = UIFont(name:kHurricaneFont_SemiBold, size: (IS_IPAD ? 26:20))
        noActiveStormsHeaderView.labelTitle.text = kStormTitle
        noActiveStormsHeaderView.labelTitle.numberOfLines = (IS_IPAD ?2:4)
        noActiveStormsHeaderView.labelTitle.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
        noActiveStormsHeaderView.bottomLine.isHidden = true
        
            if noOfObjects != nil {
                
                if noOfObjects! > 0 {
                    return nil
                } else {
                    return noActiveStormsHeaderView
                }
            } else {
                return noActiveStormsHeaderView
            }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         // hurricane storm
         let hurricaneImageCell = (tableView.dequeueReusableCell(withIdentifier: HurricaneImageCellIdentifier)! as! HurricaneImageCell)
         hurricaneImageCell.delegate = self
         let tapGesture = UITapGestureRecognizer()
         tapGesture.addTarget(self, action: #selector(cellButtonTapped(_:)))
         hurricaneImageCell.cellButton.addGestureRecognizer(tapGesture)
         self.configureCell(hurricaneImageCell, atIndexPath: indexPath)
         
         return hurricaneImageCell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.tableStormsList.deselectRow(at: indexPath, animated: true)

    }
    
    func configureCell(_ cell: HurricaneImageCell, atIndexPath indexPath: IndexPath) {
        if fetchedResultsController.fetchedObjects?.count == 0 {
            return
        }
        print(indexPath.section)
        var correctIndexPath = indexPath
        correctIndexPath.section = 0 // HAPP-623
        let stormCenter = fetchedResultsController.object(at: correctIndexPath) as! StormCenter
        cell.nameLabel.text = stormCenter.stormName
        cell.subLabel.text = stormCenter.subhead
        cell.nameLabel.contentMode = .bottom
        cell.subLabel.contentMode = .top
        
        cell.categoryLabel.isHidden = true
        
        if indexPath.row == 0 {
            
            let imgLine = cell.viewWithTag(1234) as? UIImageView
            
            if (imgLine == nil) {
                let imageLine = UIImageView(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.size.width - 40, height: 1))
                imageLine.backgroundColor = UIColor.darkGray
                imageLine.tag = 1234
                cell.addSubview(imageLine)
            }
        }
        
        let subviews = cell.leftIconImageView.subviews
        for subView: AnyObject in subviews {
            subView.removeFromSuperview()
        }
        if stormCenter.type?.caseInsensitiveCompare(kCategoryRemnants) == ComparisonResult.orderedSame {
            cell.leftIconImageView.image = UIImage(named: kImageRemnants)!
        } else if stormCenter.type?.caseInsensitiveCompare(kCategoryPostTropicalCyclone) == ComparisonResult.orderedSame {
            cell.leftIconImageView.image = UIImage(named: kImagePostTropicalCyclone)!
        } else if stormCenter.type?.caseInsensitiveCompare(kCategoryTropicalDepression) == ComparisonResult.orderedSame {
            cell.leftIconImageView.image = UIImage(named: kImageTropicalDepression)!
        } else if stormCenter.type?.caseInsensitiveCompare(kCategoryTropicalStorm) == ComparisonResult.orderedSame {
            cell.leftIconImageView.image = UIImage(named: kImageTropicalStorm)!
        } else {
            cell.leftIconImageView.image = nil
            let customImage = SVGKImage(named: kHurricaneBackgroundImage)!
            let hurricaneBGImageView = SVGKFastImageView.init(svgkImage: customImage)
            hurricaneBGImageView?.frame = CGRect(x: 10, y: 10, width: cell.leftIconImageView.frame.size.width - 20, height: cell.leftIconImageView.frame.size.height - 20)
            cell.leftIconImageView.addSubview(hurricaneBGImageView!)
            if stormCenter.type?.caseInsensitiveCompare(kCategoryHurricane_1) == ComparisonResult.orderedSame {
                cell.categoryLabel.text = "1"
            } else if stormCenter.type?.caseInsensitiveCompare(kCategoryHurricane_2) == ComparisonResult.orderedSame {
                cell.categoryLabel.text = "2"
            } else if stormCenter.type?.caseInsensitiveCompare(kCategoryHurricane_3) == ComparisonResult.orderedSame {
                cell.categoryLabel.text = "3"
            } else if stormCenter.type?.caseInsensitiveCompare(kCategoryHurricane_4) == ComparisonResult.orderedSame {
                cell.categoryLabel.text = "4"
            } else if stormCenter.type?.caseInsensitiveCompare(kCategoryHurricane_5) == ComparisonResult.orderedSame {
                cell.categoryLabel.text = "5"
            }

            cell.categoryLabel.isHidden = false
        }
                    
    }
    
    func hurricaneImageCellDidTapped() {
        
    }
    
    @objc func cellButtonTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let currentPoint: CGPoint = gestureRecognizer.location(in: self.tableStormsList)
        let indexPath: IndexPath = self.tableStormsList.indexPathForRow(at: currentPoint)!

        if let hurricaneImageCell: HurricaneImageCell = self.tableStormsList.cellForRow(at: indexPath) as? HurricaneImageCell // happ-499
        {
            UIView.animate(withDuration: 0.038, animations: {() -> Void in
                hurricaneImageCell.alpha = 0.5
                }, completion: {(_: Bool) -> Void in
                    hurricaneImageCell.alpha = 1.0
                    self.pushToCustomDetailView(indexPath)
            })
        }
    }
    
    func pushToCustomDetailView(_ hurricaneImageCellIndexPath: IndexPath) {

        let stormCenterViewController = StormCenterViewController(nibName: "StormCenterViewController", bundle: nil)
        var tappedIndexPath = hurricaneImageCellIndexPath
        tappedIndexPath.section = 0 // HAPP-623
        let stormCenter = fetchedResultsController.object(at: tappedIndexPath) as! StormCenter
        let indexBasedSort = NSSortDescriptor(key: "index", ascending: true)
        let stormDetail = stormCenter.stormCenterDetail
        if stormDetail != nil {
            stormCenterViewController.stormCenterDetailArray = (stormDetail!.allObjects as NSArray).sortedArray(using: [indexBasedSort]) as [AnyObject]
        }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(stormCenterViewController, animated: true)
    }
    
    // MARK: - NSFetchedResultsController
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
        self.tableStormsList.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let tableView = self.tableStormsList

        var nIndexPath: IndexPath!

        switch type {
        case NSFetchedResultsChangeType.insert:
            if newIndexPath != nil {
                print(newIndexPath!.section)
                nIndexPath = newIndexPath
                nIndexPath?.section = 0
                if tableView != nil && nIndexPath != nil {
                    tableView?.insertRows(at: [nIndexPath!], with: .fade)
                }
            }
        case NSFetchedResultsChangeType.delete:
            if indexPath != nil {
                print(indexPath!.section)
                nIndexPath = indexPath
                nIndexPath?.section = 0
                if tableView != nil && nIndexPath != nil {
                    tableView?.deleteRows(at: [nIndexPath!], with: .fade)
                }
            }
        case NSFetchedResultsChangeType.update:
            if indexPath != nil {
                print(indexPath!.section)
                nIndexPath = indexPath
                nIndexPath?.section = 0
                if tableView != nil && nIndexPath != nil {
                    self.configureCell((tableView?.cellForRow(at: nIndexPath!) as! HurricaneImageCell), atIndexPath: nIndexPath!)
                }
            }
        case NSFetchedResultsChangeType.move:
            if indexPath != nil && newIndexPath != nil {

                print(indexPath!.section)
                nIndexPath = indexPath
                nIndexPath?.section = 0
                var newIndexPath2 = newIndexPath
                newIndexPath2?.section = 0
                
                if tableView != nil && nIndexPath != nil && newIndexPath2 != nil {
                    
                    tableView?.deleteRows(at: [nIndexPath!], with: .fade)
                    tableView?.insertRows(at: [newIndexPath2!], with: .fade)
                }
            }
        @unknown default:
            print("default..")
        }

    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType.insert:
            self.tableStormsList.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case NSFetchedResultsChangeType.delete:
            self.tableStormsList.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case NSFetchedResultsChangeType.move, NSFetchedResultsChangeType.update:
            break
        @unknown default:
            print("default..")
        }

    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
        self.tableStormsList.endUpdates()
    }
     
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return [.portrait, .portraitUpsideDown]
    }
    
}
