//
//  AppDelegate.swift
//  Cello Mute
//
//  Created by William Ma on 11/13/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit
import AudioKit
import NotificationBannerSwift
import SwiftNotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder {

    static let shared = UIApplication.shared.delegate as! AppDelegate

    var window: UIWindow?

}

extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.tint
        ]

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        do {
            try TenorEngine.shared.start()
        } catch {
            let message = """
            It seems as if Cello Mute is unable to process audio.
            This can happen for many reasons that I am uncertain of.

            Here is the exact error message: "\(error.localizedDescription)"
            """
            let alert = UIAlertController(title: "This is awkward", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close App", style: .destructive) { _ in
                fatalError("Unable to start engine: \(error.localizedDescription)")
            })
            window?.rootViewController?.present(alert, animated: true)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        Broadcaster.notify(AppStateObserver.self) { $0.applicationWillResignActive(application) }
    }

}

protocol AppStateObserver {

    func applicationWillResignActive(_ application: UIApplication)

}
