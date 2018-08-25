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

        // 募集者に通知を送る
        let postID = self.postDoc.data()["postUser"] as! String
        functions.httpsCallable("sendNotification").call(["postID": postID]) { (result, error) in
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
                // Segueを呼び出す
                self.performSegue(withIdentifier: "toMailBoxViewController",sender: nil)
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toMailBoxViewController" {
            // 履歴タブのViewControllerを取得する
            let viewController = self.tabBarController?.viewControllers![3] as! UINavigationController
            // 履歴タブを選択済みにする
            self.tabBarController?.selectedViewController = viewController
            
            //応募履歴を一度も表示していない場合の処理
            //親ビューであるMailBoxViewを経由して渡す
            let mailboxview = viewController.topViewController as! MailBoxViewController
            mailboxview.PartnerID = self.postDoc.data()["postUser"] as! String
            
            //応募履歴を一度は表示している場合の処理
            //直接渡して、loadviewとviewDidLoadを再度発火
            let nextView:MailBoxSearchViewController = segue.destination as! MailBoxSearchViewController
            nextView.PartnerID = self.postDoc.data()["postUser"] as! String
            nextView.loadView()
            nextView.viewDidLoad()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
