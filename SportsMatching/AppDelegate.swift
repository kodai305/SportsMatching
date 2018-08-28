//
//  AppDelegate.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/04.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

import Firebase
import FirebaseMessaging
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import SVProgressHUD

import FacebookCore
import FacebookLogin

import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //facebook認証
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // setup firestore
        // Tell Cloud Firestore to use the new Timestamp object
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // For Authentication
        if let _ = Auth.auth().currentUser {
            // ログイン中
            let storyboard:UIStoryboard =  UIStoryboard(name: "Main",bundle:nil)
            window?.rootViewController
                = storyboard.instantiateViewController(withIdentifier: "toMain")
        }
 
        // For Notification
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // APNs
        // 通知許可するかをポップアップで出す
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
            if error != nil {
                return
            }
            if granted {
                debugPrint("通知許可")
                center.delegate = self
                application.registerForRemoteNotifications()
            } else {
                debugPrint("通知拒否")
            }
        })
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SportsMatching")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    // アプリがバックグラウンド状態の時に通知を受け取った場合の処理を行う。
    //  fcmのjsonに"content_available" : true が必要
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        var msgType:String = ""
        var sender:String = ""
        
        let key: Array! = Array(userInfo.keys)
        if key == nil {
            return
        }
        for i in 0..<key.count {
            let key0 = key[i] as! String
            let value0 = userInfo["\(key0)"]
            if let stubValue = value0 {
                let UnwrapValue = String(describing: stubValue)
                // 新規応募の場合
                if (key0 == "msgType") {
                    msgType = UnwrapValue
                }
                if (key0 == "sender") {
                    sender =  UnwrapValue
                }
            }
        }
        if msgType == "NewApply" {
            // Userdefaultに保存
            var StubRecruite:[String] = []
            let defaults = UserDefaults.standard
            // XXX: 2回応募できないようにする必要がある？
            
            // 今までの応募履歴を取得
            if defaults.value(forKey: "ApplyRecruite") != nil {
                StubRecruite = defaults.value(forKey: "ApplyRecruite") as! [String]
                StubRecruite.insert(sender, at: 0)
                defaults.set(StubRecruite, forKey: "ApplyRecruite")
            } else { //応募履歴がない場合
                StubRecruite.append(sender)
                defaults.set(StubRecruite, forKey: "ApplyRecruite")
            }
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }

    
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate {
    // 通知を受け取った時に(開く前に)呼ばれるメソッド
    //background時は呼ばれない
    // "content_available" : trueがあっても
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // for analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        // fcmTokenをuser-defaultに保存
        let defaults = UserDefaults.standard
        defaults.set("aaaa" ,forKey: "background")
        print("back")
        
        completionHandler([.alert])
    }
    
    // 通知を開いた時に呼ばれるメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        completionHandler()
    }

}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        // fcmTokenをuser-defaultに保存
        let defaults = UserDefaults.standard
        defaults.set(fcmToken ,forKey: "fcmToken")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}
//facebook&Google認証用
extension AppDelegate {
    //application:openUrl:options:を追加
    @available(iOS 9.0, *)
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            let facebookLoginResult = SDKApplicationDelegate.shared.application(application,
                                                                                open: url,
                                                                                options: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! [UIApplicationOpenURLOptionsKey : Any])
            let googleLoginResult = GIDSignIn.sharedInstance().handle(url,
                                                                      sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                      annotation: [:])
            if facebookLoginResult{
                return true
            }else if googleLoginResult{
                return true
            }
            return false
    }
}

