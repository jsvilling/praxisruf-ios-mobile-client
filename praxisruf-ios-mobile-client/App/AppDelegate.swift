//
//  AppDelegate.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 22.10.21.
//

import Foundation
import Firebase
import UIKit
import SwiftKeychainWrapper

/// AppDelegate implementation
/// The AppDelegate is used to implement the integration of Firebase Cloud Messaging as Messaging Service
class AppDelegate: NSObject, UIApplicationDelegate, UISceneDelegate {
    
    private let gcmMessageIDKey = "gcm.message_id"
    
    
    /// This function initializes the FirebaseApp Configuration.
    /// It then registers AppDelegate as the delegate for Firebase Messaging as well as the delegate for UNUserNotificationCenter.
    /// Finally authorization for notification is requested and the application registers for remote notifications.
    /// After this notifications can be received.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
            FirebaseApp.configure()
            Firebase.Messaging.messaging().delegate = self
        
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
              options: authOptions,
              completionHandler: { _, _ in }
            )
            application.registerForRemoteNotifications()
            return true
      }
    
    /// This function converts the userInfo contained in a received notification to the internal model
    /// and passes it to NotificationService for processing.
    ///
    /// It is called for notifications received in the foreground as well as in the background.
    /// The received userInfo is expected to contain an NSDictionary with key "aps" which in turn is expected to contain an NSDictionary with the key "alert".
    /// If either "aps" or "alert" is missing, processing of the notification is not possible and will be aborted.
    /// Otherwise the content of the "alert" dictionary is converted into the internal Model ReceiveNotification.
    /// Missing values in the "alert" will be substituted with default Values.
    /// The ReceiveNotification is then passed to NotificationService for processing.
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let aps = userInfo["aps"] as? NSDictionary else {
            debugPrint("Invalid notification received. Notification does not contain aps info.")
            return
        }
        
        guard let alert = aps["alert"] as? NSDictionary else {
            debugPrint("Invalid notification received. APS of notification does not contain alert info")
            return
        }
        
        let sender = userInfo["senderName"] as? String ?? "UNKNOWN"
        let senderId = userInfo["senderId"] as? String ?? ""
        let title = alert["body"] as? String ?? sender
        let body = userInfo["body"] as? String ?? ""
        let version = userInfo["version"] as? String ?? "UNKNOWN"
        let notificationType = userInfo["notificationType"] as? String ?? "UNKNOWN"
        
        var textToSpeech = "false"
        if (application.applicationState == .active) {
            textToSpeech = userInfo["isTextToSpeech"] as? String ?? "false"
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
        let notification = ReceiveNotification(notificationType, version, title, body, sender, senderId, textToSpeech)
        NotificationService().receive(notification)
    }
    
    /// This function prints any error when registering for remote notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    /// This function set the apnsToken (ApplePushNotificationsToken) in Firebase Messaging.
    /// This is needed so push notifications from Firebase can be processed.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

}

extension AppDelegate: MessagingDelegate {
    
    /// This function is called when Firebase Messaging has received a new firebase token.
    /// This will happen when the App first registers with Firebase Messaging and the periodically when the token expires.
    /// The received token is passed to the Registration Service for processing.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            debugPrint("Firebase registration token was empty")
            return
        }
        RegistrationService().register(messagingToken: token)
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  /// This function is called when a notification is received in the foreground.
  /// It displays the notification banner and play the notification sound.
  /// It then extracts the userInfo from the notification and passes it to appDidReceiveMessage which will forward it to the Firebase Messaging delegate.
  /// It confirms Firbase Messaging the the Notification was received
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler([[.banner, .badge, .sound]])
  }

  /// This function is called when the notification banner of a background notification is tapped.
  /// It then extracts the userInfo from the notification and passes it to appDidReceiveMessage which will forward it to the Firebase Messaging delegate.
  /// It confirms Firbase Messaging the the Notification was received
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler()
  }
    
}

extension AppDelegate : RegistrationDelegate {

    /// This function unregisters the application with Firebase Messaging
    /// It is called from the business logic, when the user logs out.
    func unregister() {
        Messaging.messaging().deleteData(completion: { error in
            if (error != nil) {
                debugPrint(error!.localizedDescription)
            }
        });
    }
}

