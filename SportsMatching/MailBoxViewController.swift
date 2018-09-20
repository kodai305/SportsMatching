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
        
        //バーの色
        settings.style.buttonBarBackgroundColor = UIColor(red: 73/255, green: 72/255, blue: 62/255, alpha: 1)
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = UIColor(red: 73/255, green: 72/255, blue: 62/255, alpha: 1)
        //セルの文字色
        settings.style.buttonBarItemTitleColor = UIColor.white
        //セレクトバーの色
        settings.style.selectedBarBackgroundColor = UIColor.yellow
        
        //描画領域がNavigationBarの下に潜り込まないように設定
        self.edgesForExtendedLayout = .bottom
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //        handle = Auth.addStateDidChangeListener()
        Auth.auth().addStateDidChangeListener { (auth, user) in
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
        // Mainを変えようとするとなぜか上手くいかない
        firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecruiteHistory") as! MailBoxRecruiteViewController
        secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchHistory") as! MailBoxSearchViewController
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //管理されるViewControllerを返す処理
        setViewController()
        let childViewControllers:[UIViewController] = [firstVC, secondVC ]
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
