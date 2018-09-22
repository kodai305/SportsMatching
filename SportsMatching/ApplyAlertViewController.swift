//
//  ApplyAlertViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/09/17.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import FirebaseFunctions
import SVProgressHUD
import FirebaseFirestore

class ApplyAlertViewController: BaseViewController {
    
    var postID:String!
    
    @IBOutlet weak var AlertTitleLabel: UILabel!
    @IBOutlet weak var AlertSubscriptionLabel: UILabel!
    @IBOutlet weak var MessageTextView: UITextView!
    
    lazy var functions = Functions.functions()
    @IBAction func SendButtonTapped(_ sender: Any) {
        // XXX: textviewが空だったら警告を出す
        let message = MessageTextView.text
        if message == "" {
            SVProgressHUD.showError(withStatus: "メッセージは空では送れません.")
            return
        }
        // 自分の名前を取得
        var myName:String = "no name"
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "profile") {
            let profile = try? JSONDecoder().decode(Profile.self, from: data)
            myName = (profile?.UserName)!
        }
        
        // メッセージの送信
        self.functions.httpsCallable("sendNewApplyNotification").call(["postID": self.postID, "message": message, "userName": myName]) { (result, error) in
            print(result?.data as Any)
            print("function is called")
            if let error = error as NSError? {
                SVProgressHUD.showError(withStatus: "失敗")
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                }
                return
            }
            SVProgressHUD.showSuccess(withStatus: "成功")
            // 応募履歴にデータを追加
            self.addApplyHistoryArray(postID: self.postID)
            
            // 投稿内容をUserDefaultに保存(トーク履歴)
            var myUID = ""
            let defaults = UserDefaults.standard
            myUID = defaults.string(forKey: "UID")!
            let roomID = myUID+"-"+self.postID
            var stubMessageInfo = MessageInfo()
            stubMessageInfo.message  = message!
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
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(self.postID)
            docRef.getDocument { (document, error) in
                guard let document = document, document.exists else {
                    SVProgressHUD.showError(withStatus: "ユーザー情報取得失敗")
                    return
                }
                
                if let tmp = document.data()!["userName"] {
                    postUserName = tmp as! String
                }
                defaults.set(postUserName, forKey: "user_"+self.postID)
            }
            // キーボードをしまう
            self.MessageTextView.resignFirstResponder()
            // このアラートビューを表示しているビューコントローラー
            let originVc = self.presentingViewController
            // 履歴タブのViewControllerを取得する
            let viewController = originVc?.tabBarController?.viewControllers![3] as! UINavigationController
            // 履歴タブを選択済みにする
            originVc?.tabBarController?.selectedViewController = viewController
            // 募集履歴と応募履歴タブの親Viewを取得し、Flagに値を渡す
            let nextViewController = viewController.topViewController as! MailBoxViewController
            nextViewController.fromSendButtonFlag = 1
            //　アラートビューを消す
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func CancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
 
    //前のビューから値を受け取る
    func setPostID(_ str:String){
        postID = str
        print("postID:"+self.postID)
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

/**
 *  Show ---------------------
 */
extension ApplyAlertViewController {
    class func show(presentintViewController vc: UIViewController) {
        guard let alert = UIStoryboard(name: "ApplyAlertViewController", bundle: nil).instantiateInitialViewController() as? ApplyAlertViewController else { return }
        vc.present(alert, animated: true, completion: nil)
    }
}
