//
//  AppCheckUpdateOnStore.swift
//  Hurricane
//
//  Created by Gaurav Purohit on 21/05/24.
//  Copyright © 2024 PNSDigital. All rights reserved.
//
import Foundation
import UIKit

// MARK: - Enum Errors
enum VersionError: Error {
    case invalidBundleInfo, invalidResponse, dataError
}

// MARK: - Models
struct LookupResult: Decodable {
    let results: [AppInfo]?
}

struct Attributes: Decodable {
    let version: String
    let expired: String
}

struct AppInfo: Decodable {
    let version: String
    let trackViewUrl: String
}


// MARK: - Check Update Class
class AppCheckUpdateOnStore: NSObject {

    // MARK: - Singleton
    static let shared = AppCheckUpdateOnStore()
    
    // MARK: - Show Update Function
    func showUpdate(withConfirmation: Bool) {
        DispatchQueue.global().async {
            self.checkVersion(force : !withConfirmation)
        }
    }

    // MARK: - Function to check version
    private  func checkVersion(force: Bool) {
        if let currentVersion = self.getBundle(key: "CFBundleShortVersionString") {
            _ = getAppInfo { (info, error) in
                
                let store = "AppStore"
                
                if let error = error {
                    print("error getting app \(store) version: ", error)
                }
                
                if let appStoreAppVersion = info?.version { // Check app on AppStore
                    // Check if the installed app is the same that is on AppStore, if it is, print on console, but if it isn't it shows an alert.
                    if appStoreAppVersion <= currentVersion {
                        print("Already on the last app version: ", currentVersion)
                    } else {
                        print("Needs update: \(store) Version: \(appStoreAppVersion) > Current version: ", currentVersion)
                        DispatchQueue.main.async {
                            let topController: UIViewController = (UIApplication.shared.windows.first?.rootViewController)!
                            topController.showAppUpdateAlert(version: appStoreAppVersion, force: force, appURL: (info?.trackViewUrl)!)
                        }
                    }
                } else { // App doesn't exist on store
                    print("App does not exist on \(store)")
                }
            }
        } else {
            print("Erro to decode app current version")
        }
    }
    
    private func getUrl(from identifier: String) -> String {
        let appStoreURL = "http://itunes.apple.com/us/lookup?bundleId=\(identifier)"
        return appStoreURL
    }

    private func getAppInfo(completion: @escaping (AppInfo?, Error?) -> Void) -> URLSessionDataTask? {

        guard let identifier = self.getBundle(key: "CFBundleIdentifier"),
              let url = URL(string: getUrl(from: identifier)) else {
                DispatchQueue.main.async {
                    completion(nil, VersionError.invalidBundleInfo)
                }
                return nil
        }
        
        let request = URLRequest(url: url)
        
        // Make request
        // Fazer a requisição
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
                do {
                    if let error = error {
                        print(error)
                        throw error
                    }
                    guard let data = data else { throw VersionError.invalidResponse }
                    
                    let result = try JSONDecoder().decode(LookupResult.self, from: data)
                    print(result)
                   
                    let info = result.results?.first
                    completion(info, nil)

                } catch {
                    completion(nil, error)
                }
            }
        
        task.resume()
        return task

    }

    func getBundle(key: String) -> String? {

        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
          fatalError("Couldn't find file 'Info.plist'.")
        }
        // Add the file to a dictionary
        let plist = NSDictionary(contentsOfFile: filePath)
        // Check if the variable on plist exists
        guard let value = plist?.object(forKey: key) as? String else {
          fatalError("Couldn't find key '\(key)' in 'Info.plist'.")
        }
        return value
    }
}

// MARK: - Show Alert
extension UIViewController {
    @objc fileprivate func showAppUpdateAlert(version : String, force: Bool, appURL: String) {
        guard let appName = AppCheckUpdateOnStore.shared.getBundle(key: "CFBundleDisplayName") else { return } //Bundle.appName()

        let alertMessage = "New version is available on AppStore. Update now!"

        let alertController = UIAlertController(title: appName, message: alertMessage, preferredStyle: .alert)

        if !force {
            let notNowButton = UIAlertAction(title: "Not now", style: .default)
            alertController.addAction(notNowButton)
        }

        let updateButton = UIAlertAction(title: "Update", style: .default) { (action:UIAlertAction) in
            guard let url = URL(string: appURL) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }

        alertController.addAction(updateButton)
        self.present(alertController, animated: true, completion: nil)
    }
}
