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
    // UIDの読み取り
    let myUID: String = UserDefaults.standard.string(forKey: "UID")!
    // fcmTokenの読み取り
    let myFcmToken: String = UserDefaults.standard.string(forKey: "fcmToken")!
    
    //プロフィールが登録済みの場合、firestoreから読み取り保存
    var UserName:String!
    var Gender:String!
    var Age:String!
    var Level:String!
    var Comments:String!
    
    // 選択されたイメージ格納用
    var selectedImg = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 登録済みのプロフィールを取得
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(myUID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //ここをなくして下に移したい
                self.UserName = document.data()!["userName"] as! String
                self.Gender = document.data()!["gender"] as! String
                self.Age = document.data()!["age"] as! String
                self.Level = document.data()!["level"] as! String
                self.Comments = document.data()!["comments"] as! String
                print("Document data: \(self.UserName)")
            } else {
                print("Document does not exist")
            }
            // 登録フォーム
            self.form +++ Section(header: "ユーザー情報", footer: "すべての項目を入力してください")
                <<< TextRow("UserName") {
                    $0.title = "ユーザー名"
                    $0.placeholder = "相手に表示される名前"
                    $0.value = self.UserName
            }
                <<< ActionSheetRow<String>("Gender") {
                    $0.title = "性別"
                    $0.selectorTitle = "性別を選択"
                    $0.options = ["男性", "女性"]
                    $0.value = self.Gender
                    }
                    .onPresent { from, to in
                        to.popoverPresentationController?.permittedArrowDirections = .up
                }
                <<< ActionSheetRow<String>("Age") {
                    $0.title = "年代"
                    $0.selectorTitle = "あなたの年代を選択"
                    $0.options = ["10代", "20代", "30代", "40代", "50代", "60代以上"]
                    $0.value = self.Age
                    }
                    .onPresent { from, to in
                        to.popoverPresentationController?.permittedArrowDirections = .up
                }
                <<< ActionSheetRow<String>("Level") {
                    $0.title = "バスケットの経験"
                    $0.selectorTitle = "バスケットの経験を選択"
                    $0.options = ["未経験", "初心者", "上級者"]
                    $0.value = self.Level
                    }
                    .onPresent { from, to in
                        to.popoverPresentationController?.permittedArrowDirections = .up
                }
                <<< ImageRow("Image1") {
                    $0.title = "公開される画像"
                    $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                    $0.value = UIImage(named: "activeImage")
                    $0.clearAction = .yes(style: .destructive)
                    $0.onChange { [unowned self] row in
                        self.selectedImg = row.value!
                    }
            }
            
            self.form +++ Section(header: "自由記述", footer: "不特定多数の方が見るため連絡先の掲載はお控えください")
                <<< TextAreaRow("Comments") {
                    $0.placeholder = "自由記述"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                    $0.value = self.Comments
            }
        }
        
        
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func saveUserProfileButtonPushed(_ sender: Any) {
        // タグ設定済みの全てのRowの値を取得
        let values = form.values()
        // 入力値の確認
        if values["UserName"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "ユーザー名を入力して下さい")
            return
        }else if values["Gender"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "性別を入力して下さい")
            return
        }else if values["Age"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "年代を入力して下さい")
            return
        }else if values["Level"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "競技レベルを入力して下さい")
            return
        }

        // プロフィールをfirestoreに保存
        // TODO: 登録日時/更新日時を追加
        let db = Firestore.firestore()
        db.collection("users").document(myUID).setData([
            "userName" :values["UserName"] as! String,
            "gender"   :values["Gender"] as! String,
            "age"      :values["Age"] as! String,
            "level"    :values["Level"] as! String,
            "comments" :values["Comments"].unsafelyUnwrapped == nil ? "" : values["Comments"] as! String,
            "fcmToken" :myFcmToken
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
    
    //複数選択するための関数
    @objc func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
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
