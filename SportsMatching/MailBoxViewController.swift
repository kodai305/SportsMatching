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
        
        // ここで総未読数を計算する. 募集履歴と応募履歴の切り替えでも呼ばれる箇所に実装したい.
        var unreadTotalCount = 0
        var myUID = ""
        let defaults = UserDefaults.standard
        myUID = defaults.string(forKey: "UID")!
        
        // 募集履歴を取得
        var _tmpRecruiteHistory:[String] = []
        if UserDefaults.standard.value(forKey: "RecruiteHistory") != nil {
            _tmpRecruiteHistory = UserDefaults.standard.value(forKey: "RecruiteHistory") as! [String]
        }
        for partnerID in _tmpRecruiteHistory {
            let roomID = myUID+"-"+partnerID
            let unreadCount = getUnreadCount(_roomID: roomID)
            if unreadCount > 0 {
                unreadTotalCount += unreadCount
            }
        }
        
        // 応募履歴の取得
        var _tmpApplyHistory:[String] = []
        if defaults.value(forKey: "ApplyHistory") != nil {
            _tmpApplyHistory = defaults.value(forKey: "RecruiteHistory") as! [String]
        }
        for partnerID in _tmpApplyHistory {
            let roomID = partnerID+"-"+myUID
            let unreadCount = getUnreadCount(_roomID: roomID)
            if unreadCount > 0 {
                unreadTotalCount += unreadCount
            }
        }
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
    
    func getUnreadCount(_roomID: String) -> (Int) {
        var _unreadCount = 0
        let defaults = UserDefaults.standard
        // ルームIDが_roomIDの総メッセージ数を取得
        var _totalMessageCount = 0
        guard let tmpData = defaults.data(forKey: _roomID) else {
            // データがなかったら0を返す
            return 0
        }
        let _savedMessageInfoArray = try? JSONDecoder().decode([MessageInfo].self, from: tmpData)
        _totalMessageCount = _savedMessageInfoArray!.count
        // ルームIDが_roomIDの表示済みメッセージ数を取得
        let _key = "DisplayedNumber_"+_roomID
        let _displayedCount = defaults.integer(forKey: _key)
        // [未読数] = [メッセージ総数] - [表示済]
        _unreadCount = _totalMessageCount - _displayedCount
        
        return _unreadCount
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
