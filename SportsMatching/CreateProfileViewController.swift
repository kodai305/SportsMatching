//
//  CreateProfileViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/19.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD

class CreateProfileViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: 既に保存してあるデータの読込
        // TODO: 保存してあるデータが有れば入力値に初期値として代入する
        
        // 登録フォーム
        form +++ Section(header: "ユーザー情報", footer: "すべての項目を入力してください")
            <<< TextRow("userRealName") {
                $0.title = "ユーザー名"
                $0.placeholder = "相手に表示される名前"
            }
        
        
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func saveUserProfileButtonPushed(_ sender: Any) {
        // タグ設定済みの全てのRowの値を取得
        let values = form.values()
        // 入力値の確認
        if values["userRealName"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "ユーザー名を入力して下さい")
            return
        }
        
        // UIDの読み取り
        let myUID: String = UserDefaults.standard.string(forKey: "UID")!
        // fcmTokenの読み取り
        let myFcmToken: String = UserDefaults.standard.string(forKey: "fcmToken")!

        // プロフィールをfirestoreに保存
        // TODO: 登録日時/更新日時を追加
        let db = Firestore.firestore()
        db.collection("users").document(myUID).setData([
            "userRealName" :values["userRealName"] as! String,
            "fcmToken"     :myFcmToken
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                SVProgressHUD.showSuccess(withStatus: "登録成功")
                // TODO: 1秒待ったほうがいいかも？
                // MyPageへ遷移する
                self.show((self.storyboard?.instantiateViewController(withIdentifier: "MyPage"))!,sender: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
