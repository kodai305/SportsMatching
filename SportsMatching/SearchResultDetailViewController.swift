//
//  DetailViewController.swift
//  SportsMatching
//
//  Created by user on 2018/08/08.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFunctions
import FirebaseFirestore
import SVProgressHUD

class SearchResultDetailViewController: BaseViewController{
    //検索結果一覧からデータを受け取る変数
    var postDoc:QueryDocumentSnapshot!
    var selectedImg:UIImage!
    
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
        DetailImage.image = selectedImg
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        DetailImage.contentMode = UIViewContentMode.scaleAspectFit
        TeamNameLabel.text = self.postDoc.data()["teamName"] as? String
        PrefectureLabel.text = self.postDoc.data()["prefecture"] as? String
    }
    
    // 応募ボタンを押して募集者にメッセージを送る
    lazy var functions = Functions.functions()
    @IBAction func entryButtonTapped(_ sender: Any) {
        // XXX:ポップアップを出して応募メッセージ入力フォーマットを出す？

        let alert = UIAlertController(title:"投稿者へメッセージ", message:"message", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: nil)

        let okAction = UIAlertAction(title:"送信",style: UIAlertActionStyle.default){(action:UIAlertAction) in
            if let textField = alert.textFields?.first {  // ?? .first
                let messageStr:String = textField.text!
                if (messageStr.isEmpty) {
                    // XXX: 入力されてなかったときの処理
                    SVProgressHUD.showError(withStatus: "メッセージを入力してください")
                    return
                }
                SVProgressHUD.show(withStatus: "送信中")
                // 募集者に通知を送る
                let postID = self.postDoc.data()["postUser"] as! String
                self.functions.httpsCallable("sendNotification").call(["postID": postID, "message": messageStr]) { (result, error) in
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
                        
                        // 履歴タブのViewControllerを取得する
                        let viewController = self.tabBarController?.viewControllers![3] as! UINavigationController
                        // 履歴タブを選択済みにする
                        self.tabBarController?.selectedViewController = viewController
                        //stororyboard内であることをここで定義
                        let storyboard: UIStoryboard = self.storyboard!
                        //移動先のstoryboardを選択
                        let nextView = storyboard.instantiateViewController(withIdentifier: "SearchHistory")
                        //移動する
                        self.show(nextView, sender: nil)
                    }
                }

            }
        }
        alert.addAction(okAction)
        let cancelButton = UIAlertAction(title: "キャンセル",style:UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }

    func addApplyHistoryArray(postID: String) {
        var StubApplyHistory:[String] = []
        let defaults = UserDefaults.standard
        //今までの応募履歴を取得
        if defaults.value(forKey: "ApplyHistory") != nil {
            StubApplyHistory = defaults.value(forKey: "ApplyHistory") as! [String]
            StubApplyHistory.insert(postID, at: 0)
            defaults.set(StubApplyHistory, forKey: "ApplyHistory")
        } else { //応募履歴がない場合
            StubApplyHistory.append(postID)
            defaults.set(StubApplyHistory, forKey: "ApplyHistory")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
