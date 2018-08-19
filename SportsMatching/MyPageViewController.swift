//
//  MyPageViewController.swift
//  SportsMatching
//
//  Created by user on 2018/08/15.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MyPageViewController: BaseViewController {
    
    let db = Firestore.firestore()
    //自分のID
    let senderId = "test7"
    //チャット相手のID
    let partnerId = "test8"
    //起動時のメッセージ数
    var InitialMessagesNumber:Int = 0
    //交換したメッセージ数
    var MessagesNumber:Int = 0
    //SnapShot内の処理が画面遷移時に起動しない様に管理
    var SnapFlag = 0
    
    var listener:ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //firestoreのおまじない（入れないとコンソールで警告）
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        //チャット相手が送信したメッセージを自動で取得
        listener = db.collection("rooms-matsue").document("test7_test8")
            .collection("messages").whereField("user", isEqualTo: partnerId)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                if self.SnapFlag != 0{
                    self.MessagesNumber = documents.map { $0["body"]! }.count
                    if let tabItem = self.tabBarController?.tabBar.items?[3] {
                        tabItem.badgeValue = String(self.MessagesNumber - self.InitialMessagesNumber)
                    }
                }else{
                    self.SnapFlag = 1
                    self.InitialMessagesNumber = documents.map { $0["body"]! }.count
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //FireStoreへの問い合わせを停止
        listener.remove()
        if let tabItem = self.tabBarController?.tabBar.items?[3] {
            tabItem.badgeValue = nil
        }
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
