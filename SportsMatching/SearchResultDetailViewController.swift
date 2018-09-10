//
//  DetailViewController.swift
//  SportsMatching
//
//  Created by user on 2018/08/08.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import FirebaseCore
import FirebaseFunctions
import FirebaseFirestore
import SVProgressHUD

class SearchResultDetailViewController: BaseFormViewController{
    //検索結果一覧からデータを受け取る変数
    var postDoc:QueryDocumentSnapshot!
    var selectedImg:UIImage!
    
    let myUID: String = UserDefaults.standard.string(forKey: "UID")!
    
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    // メッセージの構造体(保存用)
    // 二重定義になってしまうのをなんとかしたいいつか
    struct MessageInfo: Codable {
        var message: String = ""
        var senderID: String = ""
        var sentDate: Date = Date()
        var kind: String = ""
    }
    
    @IBOutlet weak var DetailImage: UIImageView!
    @IBOutlet weak var TeamNameLabel: UILabel!
    @IBOutlet weak var PrefectureLabel: UILabel!
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //検索結果一覧から受け取ったデータを表示
        DetailImage.frame.size = CGSize(width: 200, height: 200)
        DetailImage.frame.origin.y = 0
        DetailImage.image = selectedImg
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        DetailImage.contentMode = UIViewContentMode.scaleAspectFit
        TeamNameLabel.text = self.postDoc.data()["teamName"] as? String
        PrefectureLabel.text = self.postDoc.data()["prefecture"] as? String
        
        // 上部に画像を設定
        form +++ Section(){ section in
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    return self.DetailImage
                }))
                header.height = { 200 }
                return header
            }()
        }
        
        +++ Section(header: "投稿の詳細", footer: "")
            <<< TextRow("TeamName") {
                $0.title = "チーム名"
                $0.value = self.postDoc.data()["teamName"] as? String
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("Category") {
                $0.title = "カテゴリ"
                $0.value = self.postDoc.data()["category"] as? String
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("Prefecture") {
                $0.title = "都道府県"
                $0.value = self.postDoc.data()["prefecture"] as? String
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("Place"){
                $0.title = "活動場所"
                $0.value = self.postDoc.data()["place"] as? String
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("ApplyGender") {
                $0.title = "募集性別"
                $0.value = self.postDoc.data()["applyGender"] as? String
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("Timezone") {
                $0.title = "活動時間帯"
                $0.value = self.ArraytoSting(array: postDoc.data()["timezone"] as! Array<String>)
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("Position") {
                $0.title = "募集ポジション"
                $0.value = self.ArraytoSting(array: postDoc.data()["position"] as! Array<String>)
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("ApplyLevel") {
                $0.title = "参加可能なレベル"
                $0.value = self.ArraytoSting(array: postDoc.data()["applyLevel"] as! Array<String>)
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("GenderRatio") {
                $0.title = "チーム構成"
                $0.value = self.postDoc.data()["genderRatio"] as? String
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("TeamLevel") {
                $0.title = "チームのレベル"
                $0.value = self.postDoc.data()["teamLevel"] as? String
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("NumMembers"){
                $0.title = "チームの人数"
                $0.value = String(self.postDoc.data()["numMembers"] as! Int)
                $0.baseCell.isUserInteractionEnabled = false
            }
            
            <<< TextRow("Day") {
                $0.title = "開催曜日"
                $0.value = self.ArraytoSting(array: postDoc.data()["day"] as! Array<String>)
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("MainAge") {
                $0.title = "メンバー年齢"
                $0.value = self.ArraytoSting(array: postDoc.data()["mainAge"] as! Array<String>)
                $0.baseCell.isUserInteractionEnabled = false
        }
            <<< TextAreaRow("Comments") {
                $0.value = self.postDoc.data()["comments"] as? String
                $0.baseCell.isUserInteractionEnabled = false
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
        }
        
    }
    
    // 応募ボタンを押して募集者にメッセージを送る
    lazy var functions = Functions.functions()
    @IBAction func entryButtonTapped(_ sender: Any) {
        //プロフィールが作成済みかをチェック
        //usersコレクションから条件に一致するドキュメントを取得
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(myUID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //プロフィールが作成済みの場合
                print("Profile exists")
                // XXX:ポップアップを出して応募メッセージ入力フォーマットを出す？
                let msg:String = "内容\n\n\n\n"
                let alert = UIAlertController(title:"投稿者へメッセージ", message:msg, preferredStyle: UIAlertControllerStyle.alert)
                //        alert.addTextField(configurationHandler: nil)
                
                let textView = UITextView(frame: CGRect(x: 10, y:60, width:CGFloat(250), height:CGFloat(80)))
                textView.text = "hoge"
                textView.layer.borderColor = UIColor.lightGray.cgColor
                textView.layer.borderWidth = 0.5
                textView.layer.cornerRadius = 6
                alert.view.addSubview(textView)
                
                // 画面が開いたあとでないと textView にフォーカスが当たらないため、遅らせて実行する
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    textView.becomeFirstResponder()
                }
                
                let okAction = UIAlertAction(title:"送信",style: UIAlertActionStyle.default){(action:UIAlertAction) in
                    //            if let textField = alert.textFields?.first {  // ?? .first
                    if (textView.text != nil) {
                        let messageStr:String = textView.text!
                        //                let messageStr:String = textField.text!
                        if (messageStr.isEmpty) {
                            // XXX: 入力されてなかったときの処理
                            SVProgressHUD.showError(withStatus: "メッセージを入力してください")
                            return
                        }
                        SVProgressHUD.show(withStatus: "送信中")
                        // 募集者に通知を送る
                        let postID = self.postDoc.data()["postUser"] as! String
                        
                        //自分の名前を取得
                        var myName:String = "no name"
                        let defaults = UserDefaults.standard
                        if let data = defaults.data(forKey: "profile") {
                            let profile = try? JSONDecoder().decode(Profile.self, from: data)
                            myName = (profile?.UserName)!
                        }
                        print("myName:")
                        print(myName)
                        self.functions.httpsCallable("sendNewApplyNotification").call(["postID": postID, "message": messageStr, "userName": myName]) { (result, error) in
                            print(result?.data as Any)
                            print("function is called")
                            if let error = error as NSError? {
                                SVProgressHUD.showError(withStatus: "失敗")
                                if error.domain == FunctionsErrorDomain {
                                    let code = FunctionsErrorCode(rawValue: error.code)
                                    let message = error.localizedDescription
                                    let details = error.userInfo[FunctionsErrorDetailsKey]
                                }
                            } else {
                                SVProgressHUD.showSuccess(withStatus: "成功")
                                // 応募履歴にデータを追加
                                self.addApplyHistoryArray(postID: postID)
                                
                                // 投稿内容をUserDefaultに保存(トーク履歴)
                                var myUID = ""
                                let defaults = UserDefaults.standard
                                myUID = defaults.string(forKey: "UID")!
                                let roomID = myUID+"-"+postID
                                var stubMessageInfo = MessageInfo()
                                stubMessageInfo.message  = messageStr
                                stubMessageInfo.senderID = myUID
                                stubMessageInfo.sentDate = Date()
                                stubMessageInfo.kind     = "text"
                                // 保存するmessageInfo配列
                                var messageArray:[MessageInfo] = []
                                messageArray.append(stubMessageInfo)
                                let data = try? JSONEncoder().encode(messageArray)
                                defaults.set(data ,forKey: roomID)
                                
                                // 募集者のプロフィールを取得->保存
                                var postUserName = "no name"
                                let docRef = db.collection("users").document(postID)
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let tmp = document.data()!["userName"] {
                                            postUserName = tmp as! String
                                        }
                                        defaults.set(postUserName, forKey: "user_"+postID)
                                        // 履歴タブのViewControllerを取得する
                                        let viewController = self.tabBarController?.viewControllers![3] as! UINavigationController
                                        // 履歴タブを選択済みにする
                                        self.tabBarController?.selectedViewController = viewController
                                    } else {
                                        print("Document does not exist")
                                    }
                                }
                            }
                        }
                    }
                }
                alert.addAction(okAction)
                let cancelButton = UIAlertAction(title: "キャンセル",style:UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(cancelButton)
                self.present(alert, animated: true, completion: nil)
            } else {
                //プロフィールが存在しない場合
                SVProgressHUD.showError(withStatus: "応募にはプロフィールの作成が必要です")
                // マイページタブのViewControllerを取得する
                let viewController = self.tabBarController?.viewControllers![0] as! UINavigationController
                // マイページタブを選択済みにする
                self.tabBarController?.selectedViewController = viewController
                return
            }
        }
    }

    func addApplyHistoryArray(postID: String) {
        var StubApplyHistory:[String] = []
        let defaults = UserDefaults.standard
        // XXX: 2回応募できないようにする必要がある？
        
        // 今までの応募履歴を取得
        if defaults.value(forKey: "ApplyHistory") != nil {
            StubApplyHistory = defaults.value(forKey: "ApplyHistory") as! [String]
            StubApplyHistory.insert(postID, at: 0)
            defaults.set(StubApplyHistory, forKey: "ApplyHistory")
        } else { //応募履歴がない場合
            StubApplyHistory.append(postID)
            defaults.set(StubApplyHistory, forKey: "ApplyHistory")
        }
    }
    
    //Set型の中身を単独のStingにまとめて返す
    func ArraytoSting(array: Array<String>) -> String?{
        if array.isEmpty{
            return nil
        }else{
            var string:String!
            for i in 0 ..< array.count {
                string = i == 0 ? array[i] : array[i] + "," + string
            }
            return string
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
