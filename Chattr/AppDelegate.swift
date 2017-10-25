//
//  AppDelegate.swift
//  Chattr
//
//  Created by Neo Ighodaro on 23/10/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//


import UIKit

struct AppConstants {
    static let ENDPOINT    = "http://localhost:4000"
    static let INSTANCE_ID = "v1:us1:1e993c48-d331-47f3-bbbe-4b6129e7c81d"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.backgroundColor = UIColor.white
        return true
    }
}

