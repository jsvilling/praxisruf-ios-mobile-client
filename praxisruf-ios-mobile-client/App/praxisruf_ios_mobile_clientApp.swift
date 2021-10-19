//
//  praxisruf_ios_mobile_clientApp.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 17.10.21.
//

import SwiftUI
import Firebase

@main
struct praxisruf_ios_mobile_clientApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
            }
            .navigationViewStyle(.stack)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Setup Firebase
        FirebaseMessaging.Messaging.messaging().delegate = self
        
        // Setup Notifications
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
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
    }}

// Cloud Messaging
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Received token \(fcmToken)")
        UserDefaults.standard.setValue(fcmToken, forKey: fcmToken ?? "")
    }
}

// User Notifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    
}
