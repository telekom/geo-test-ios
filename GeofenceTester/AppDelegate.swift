/*
 * telekom / geo-test-ios
 *
 * AppDelegate.swift
 * Created by Alexander von Below on 10.06.22.
 * Copyright (c) 2022 Deutsche Telekom AG
 *
 * This program is made available under the terms of the 
 * MIT license which is available at
 * https://opensource.org/licenses/MIT
 *
 * SPDX-License-Identifier: MIT 
 */

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute
import CoreLocation
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var locationManager = CLLocationManager()
    var locationDelegate = CoreLocationDelegate()
    var errorHandler = ErrorHandler()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppCenter.start(withAppSecret: AppCenterKey,
                        services:[
                            Analytics.self,
                            Crashes.self,
                            Distribute.self
                        ])
        UserDefaults.standard.register(defaults: [PausesVisitAutomatically: true])

        self.locationDelegate.errorHandler = errorHandler
        self.locationManager.delegate = self.locationDelegate
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

