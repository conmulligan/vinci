//
//  AppDelegate.swift
//  Vinci
//
//  Created by conmulligan on 04/27/2018.
//  Copyright (c) 2018 Conor Mulligan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let directory = urls[urls.count - 1]
        print("Documents URL: \(directory)")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    
    }

    func applicationWillTerminate(_ application: UIApplication) {
    
    }
}
