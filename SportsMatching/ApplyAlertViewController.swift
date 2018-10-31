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
    @IBOutlet weak var AlertUIView: UIView!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var SendButton: UIButton!
    
    lazy var functions = Functions.functions()
    @IBAction func SendButtonTapped(_ sender: Any) {
        // textviewが空だったら警告を出す
        let message = MessageTextView.text
        if message == "" {
            SVProgressHUD.showError(withStatus: "メッセージは空では送れません.")
            return
        }
        SVProgressHUD.show(withStatus: "送信中")
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
            var postUserName = "NO NAME"
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(self.postID)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let tmp = document.data()!["userName"] {
                        postUserName = tmp as! String
                    }
                } else {
                    print("ユーザー情報取得失敗")
                }
                
                defaults.set(postUserName, forKey: "user_"+self.postID)
                // キーボードをしまう
                self.MessageTextView.resignFirstResponder()
                // このアラートビューを表示しているビューコントローラー
                let originVc = self.presentingViewController
                
                // メッセージ履歴のViewControllerを取得する
                let viewController = originVc?.tabBarController?.viewControllers![3] as! UINavigationController
                // メッセージ履歴のTabBarを表示する
                viewController.tabBarController?.tabBar.isHidden = false
                // 履歴タブを選択済みにする
                originVc?.tabBarController?.selectedViewController = viewController
                // 募集履歴と応募履歴タブの親Viewを取得し、Flagに値を渡す
                let nextViewController = viewController.topViewController as! MailBoxViewController
                nextViewController.fromSendButtonFlag = 1
                //　アラートビューを消す
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    @IBAction func CancelButtonTapped(_ sender: Any) {
        //Navigation Controllerを取得
        let nav = self.presentingViewController  as! UINavigationController
        //呼び出し元のTabBarを表示する
        let previousVc = nav.viewControllers[nav.viewControllers.count-1] as! SearchResultDetailViewController
        previousVc.tabBarController?.tabBar.isHidden = false
        //閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor(hex: "FFFFFF", alpha: 0.4)
        //　アラートのレイアウト
        self.AlertUIView.frame =
            CGRect(x: self.view.frame.width * 1 / 20, y: self.view.frame.height / 20, width: self.view.frame.width * 9 / 10, height: self.view.frame.height * 9 / 20)
        self.AlertUIView.layer.cornerRadius = 20
        self.AlertUIView.backgroundColor = UIColor(hex: "F4F6F6")
        
        // ラベルの設定
        self.AlertTitleLabel.sizeToFit()
        self.AlertTitleLabel.center.x = self.AlertUIView.frame.width / 2
        self.AlertTitleLabel.frame.origin.y = 20
        
        self.AlertSubscriptionLabel.sizeToFit()
        self.AlertSubscriptionLabel.center.x = self.AlertUIView.frame.width / 2
        self.AlertSubscriptionLabel.frame.origin.y = self.AlertTitleLabel.frame.origin.y + self.AlertTitleLabel.frame.height + 10
        
        // キャンセル、送信ボタンの設定
        self.CancelButton.frame.size = CGSize(width: self.AlertUIView.frame.width / 2, height: 50)
        self.CancelButton.frame.origin = CGPoint(x: 0, y:  self.AlertUIView.frame.height - self.CancelButton.frame.height)
        // 背景より濃いグレーで枠線
        self.CancelButton.layer.borderColor = UIColor(hex: "D5DBDB").cgColor
        self.CancelButton.layer.borderWidth = 1
        // 左下のみ角を丸くする
        self.CancelButton.layer.cornerRadius = 20
        self.CancelButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        // タップした時に背景色が濃い灰色になる
        self.CancelButton.setBackgroundColor(UIColor(hex: "CCD1D1"), for: .highlighted)
        
        self.SendButton.frame.origin = CGPoint(x: self.AlertUIView.frame.width / 2, y:  self.CancelButton.frame.origin.y)
        self.SendButton.frame.size = CGSize(width: self.AlertUIView.frame.width / 2, height: 50)
        self.SendButton.layer.borderColor = UIColor(hex: "D5DBDB").cgColor
        self.SendButton.layer.borderWidth = 1
        // 右下のみ角を丸くする
        self.SendButton.layer.cornerRadius = 20
        self.SendButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        // タップした時に背景色が濃い灰色になる
        self.SendButton.setBackgroundColor(UIColor(hex: "CCD1D1"), for: .highlighted)
        
        // メッセージ入力用のtextviewの設定
        // サブタイトルとボタンの間隔から大きさを決める
        self.MessageTextView.frame.size = CGSize(width: self.AlertUIView.frame.width * 4 / 5, height: self.CancelButton.frame.origin.y - (self.AlertSubscriptionLabel.frame.origin.y + self.AlertSubscriptionLabel.frame.height) - 30)
        self.MessageTextView.center.x = self.AlertUIView.frame.width / 2
        self.MessageTextView.frame.origin.y = self.AlertSubscriptionLabel.frame.origin.y + self.AlertSubscriptionLabel.frame.height + 10
        // Do any additional setup after loading the view.
    }

    func addApplyHistoryArray(postID: String) {
        var StubApplyHistory:[String] = []
        let defaults = UserDefaults.standard
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
