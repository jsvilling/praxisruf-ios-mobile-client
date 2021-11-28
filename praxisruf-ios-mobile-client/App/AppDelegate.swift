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

        guard let aps = userInfo["aps"] as? NSDictionary else {
            print("no aps")
            return
        }

        guard let alert = aps["alert"] as? NSDictionary else {
            print("no alert")
            return
        }

        guard let title = alert["title"] as? String else {
            print("no title")
            return
        }

        guard let body = alert["body"] as? String else {
            print("no body")
            return
        }

        guard let sender = userInfo["senderName"] as? String else {
            print("no sender")
            return
        }

        guard let version = userInfo["version"] as? String else {
          print("no version")
          return
        }

        guard let isTextToSpeech = userInfo["isTextToSpeech"] as? String else {
          print("no t2s flag")
          return
        }

        guard let notificationType = userInfo["notificationType"] as? String else {
          print("no notification type")
          return
        }
        
        completionHandler([[.banner, .badge, .sound]])
        Inbox.shared.receiveNofication(title: title, body: body, sender: sender)
        if (isTextToSpeech == "true") {
          SpeechSynthesisService().synthesize(notificationType: notificationType, version: version)
        }
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
