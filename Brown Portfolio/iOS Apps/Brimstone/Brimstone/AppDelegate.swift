//
//  AppDelegate.swift
//  Brimstone
//
//  Created by Priyanjoli Mukherjee & Christopher Brown on 1/20/19.
//  Copyright © 2019 Centaur Games. All rights reserved.
//

import UIKit
import StoreKit

struct StoreKitHelper {
    static let numberOfTimesLaunchedKey = "numberOfTimesLaunched"
    
    static func displayStoreKit() {
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else {
            return
        }
        
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersion")
        let numberOfTimesLaunched: Int = UserDefaults.standard.integer(forKey: StoreKitHelper.numberOfTimesLaunchedKey)
        
        if numberOfTimesLaunched > 2 && currentVersion != lastVersionPromptedForReview {
            if #available(iOS 10.3,*) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(currentVersion,forKey: "lastVersion")
            }
        }
    }
    
    static func incrementNumberOfTimesLaunched() {
        let numberOfTimesLaunched: Int = UserDefaults.standard.integer(forKey: StoreKitHelper.numberOfTimesLaunchedKey) + 1
        UserDefaults.standard.set(numberOfTimesLaunched, forKey: StoreKitHelper.numberOfTimesLaunchedKey)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        StoreKitHelper.incrementNumberOfTimesLaunched()
        StoreKitHelper.displayStoreKit()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

