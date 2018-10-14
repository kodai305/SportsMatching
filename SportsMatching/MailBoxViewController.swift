//
//  MailBoxViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/08.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase

class MailBoxViewController: ButtonBarPagerTabStripViewController {
    @IBAction func comeHome (segue: UIStoryboardSegue){
    }
    
    var firstVC:MailBoxRecruiteViewController!
    var secondVC:MailBoxSearchViewController!
    var PartnerID:String!
    
    var fromSendButtonFlag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //バーの色
        settings.style.buttonBarBackgroundColor = UIColor(hex: "E59866")
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = UIColor(hex: "E59866")
        //セルの文字色
        settings.style.buttonBarItemTitleColor = UIColor.black
        //セレクトバーの色
        settings.style.selectedBarBackgroundColor = UIColor(hex: "d45000")
    
        //描画領域がNavigationBarの下に潜り込まないように設定
        self.edgesForExtendedLayout = .bottom
        
        print("DidLoad is called")
        
        // Do any additional setup after loading the view.
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //        handle = Auth.addStateDidChangeListener()
        print("willAppear is called")
        Auth.auth().addStateDidChangeListener { (auth, user) in
            // ↓必要?? 10/08 takagi 記載
            // [START_EXCLUDE]
            if user != nil{
                //サインインしている
                print("user:")
                print(user?.uid)
            } else {
                //サインインしていない
                print("ログインをしてください")
            }
            // [END_EXCLUDE]
            // ↑ここまで
        }
        
        //バッジの設定
        setBadge()
    }
    
    func setBadge() {
        print("setBadge is called")
        
        let unreadTotalCount = Budge().getTotalUnreadCount()
        // TabBarのバッジとアプリアイコンのバッジを表示する
        if unreadTotalCount > 0 {
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = String(unreadTotalCount)
            UIApplication.shared.applicationIconBadgeNumber = unreadTotalCount
        } else {
            self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(fromSendButtonFlag)
        //fromSendButtonFlagの値が1の場合応募ボタンからの遷移
        if fromSendButtonFlag == 1 {
        //応募ボタンからの遷移の場合、応募履歴タブをアクティブにする
            print(currentIndex)
            moveToViewController(at: 1, animated: true)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setViewController() {
        // Mainを変えようとするとなぜか上手くいかない <- このMainの意味はMain.storyboardのMain. 変えるならxx.storyboardを作ってxxを設定する
        firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecruiteHistory") as! MailBoxRecruiteViewController
        secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchHistory") as! MailBoxSearchViewController
    }
        
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //管理されるViewControllerを返す処理
        setViewController()
        let childViewControllers:[UIViewController] = [firstVC, secondVC]
        return childViewControllers
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
