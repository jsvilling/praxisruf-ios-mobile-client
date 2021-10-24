//
//  AppDelegate.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 22.10.21.
//

import Foundation
import Firebase
import UIKit

// ip6 bundle id ch.fhnw.ip6.praxisruf.praxisruf-ios-mobile-client

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication
                         .LaunchOptionsKey: Any]?) -> Bool {

            // Setup firebase configuration
            FirebaseApp.configure()

            // Setup Cloud Messaging
            Firebase.Messaging.messaging().delegate = self

            // Setup Notifications
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
              options: authOptions,
              completionHandler: { _, _ in }
            )
            application.registerForRemoteNotifications()
            return true
      }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                       -> Void) {

      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            print("Firebase registration token was empty")
            return
        }
        print("Firebase registration token: \(token)")
        let defaults = UserDefaults.standard
        defaults.setValue(token, forKey: "fcmToken")
        RegistrationService().register()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
   
    let userInfo = notification.request.content.userInfo
    Messaging.messaging().appDidReceiveMessage(userInfo)
      if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
          }
      print(userInfo)
    completionHandler([[.banner, .badge, .sound]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }
      
    Messaging.messaging().appDidReceiveMessage(userInfo)
    print(userInfo)

    completionHandler()
  }
    

}
