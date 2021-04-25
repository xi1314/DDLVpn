//
//  AppDelegate.swift
//  DDLVPNAlrd
//
//  Created by MrFeng on 2020/12/2.
//

import UIKit


struct Model {
    var services : String?
    var port : String?
    var username : String?
    var password : String?
    var whitelist : [String]?
    var blacklist : [String]?
    var localdns : String?
    var tun2socksAddr : String?
       
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = HomeViewController()
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    
}

