//
//  UIViewController+ErrorHandler.swift
//  Hurricane
//
//  Created by Swati Verma on 13/09/16.
//  Copyright © 2016 Graham Media. All rights reserved.
//

import UIKit

extension UIViewController {

    func handleNetworkError(_ error: NSError?, statusCode: Int?) {
        if error != nil {
            print("Error Code = \(Int(error!.code))")
        }
        let isError = true
        var errorTitle: String?
        var errorMessage: String?
        if AppDefaults.checkInternetConnection() {
            errorTitle = kErrorTitle_NoData
            errorMessage = kErrorMessage_NoData
        } else {
            errorTitle = kErrorTitle_NoInternet
            errorMessage = kErrorMessage_NoInternet
        }
        if isError {
            let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: kOk, style: UIAlertAction.Style.default) { (_: UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
