//
//  AppDelegate.swift
//  CatalystTestApp
//
//  Created by Umashri R on 02/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit
import ZCatalyst

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window
        {
            do
            {
                try ZCatalystApp.shared.initSDK( window : window, environment : .development )
            }
            catch
            {
                print("Error occurred... \( error )")
            }
            
            window.rootViewController = UINavigationController( rootViewController : HomeController() )
            window.makeKeyAndVisible()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

   func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        ZCatalystApp.shared.handleLoginRedirection( url, sourceApplication : sourceApplication, annotation: annotation )
        return true
    }
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceapp = options[ UIApplication.OpenURLOptionsKey.sourceApplication ]
        ZCatalystApp.shared.handleLoginRedirection( url, sourceApplication : sourceapp as? String, annotation: "" )
        return true
    }

}

