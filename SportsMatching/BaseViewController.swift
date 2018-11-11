//
//  ViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/04.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleMobileAds

class BaseViewController: UIViewController, GADBannerViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: "EBEDEF")
        // Tabbar非選択時のアイコンの色を設定
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor(hex: "515A5A")
        // Do any additional setup after loading the view, typically from a nib.
        //displayAdvertisement()
    }

    var handle: AuthStateDidChangeListenerHandle?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // When user status is changed, this pocess is executed
        Auth.auth().addStateDidChangeListener { (auth, user) in
            // [START_EXCLUDE]
            if user != nil {
                //サインインしている
                print("user:")
                print(user?.uid)
                self.saveUID(uid: (user?.uid)!)
            } else {
                //サインインしていない
                print("ログインをしてください")
                print(user?.uid as Any)
            }
            // [END_EXCLUDE]
        }
    }
    
    func saveUID (uid: String) {
        if uid.isEmpty {
            print("認証してください")
            // TODO: 警告, 認証画面への遷移ロジックを追加する
            
        } else {
            // UIDをuser defaultに保存
            // TODO: 保存してあるUIDと違ったら警告を出したほうがいいかもしれない
            let defaults = UserDefaults.standard
            defaults.set(uid ,forKey: "UID")
        }
    }

    //let admob_id = "XXX" // 本番用
    let admob_id = "ca-app-pub-3940256099942544/2934735716" // 練習用

    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    // 広告の表示
    func displayAdvertisement() {
        print("display Advertisement is called")
        var bannerView = GADBannerView()
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = admob_id
        
        let tabBarController: UITabBarController = UITabBarController()
        let tabBarHeight = tabBarController.tabBar.frame.size.height
        bannerView.frame.origin = CGPoint(x:0, y:self.view.frame.size.height - tabBarHeight - bannerView.frame.height)
        bannerView.frame.size = CGSize(width:self.view.frame.width, height:bannerView.frame.height)
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        self.view.addSubview(bannerView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

