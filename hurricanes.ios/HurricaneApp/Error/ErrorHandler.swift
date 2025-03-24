//
//  ErrorHandler.swift
//  Hurricane
//
//  Created by Swati Verma on 13/09/16.
//  Copyright © 2016 Graham Media. All rights reserved.
//

import Foundation

protocol ErrorHandler: AnyObject {
    func handleNetworkError(_ error: NSError?, statusCode: Int?)
}
