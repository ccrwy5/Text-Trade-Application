//
//  AppDelegate.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/8/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Firebase
import UserNotificationsUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let pushManager = PushNotificationManager(userID: "currently_logged_in_user_id")
        pushManager.registerForPushNotifications()
        
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true

        
        let sender = PushNotificationSender()
        sender.sendPushNotification(to: "token", title: "Notification title", body: "Notification body")

        // Override point for customization after application launch.
        
        /*let notificationTypes : UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let notificationSettings = UIUserNotificationSettings(types: notificationTypes , categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)*/
                
        return true
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
   /* private func application(_ application: UIApplication, didRecieveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        //print("MessageID : \(userInfo["gcm_message_id"]!)")
        
        print(userInfo)
    }*/
    
    


}

