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

class SearchResultDetailViewController: BaseFormViewController{
    //検索結果一覧からデータを受け取る変数
    var postDoc:QueryDocumentSnapshot!
    var selectedImg:UIImage!
    
    let myUID: String = UserDefaults.standard.string(forKey: "UID")!
    
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
            <<< TextRow("Day") {
                $0.title = "開催曜日"
                $0.value = self.ArraytoSting(array: postDoc.data()["day"] as! Array<String>)
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
            <<< TextRow("Timezone") {
                $0.title = "活動時間帯"
                $0.value = self.ArraytoSting(array: postDoc.data()["timezone"] as! Array<String>)
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
        
        form +++ Section(){ section in
            section.footer = {
                var footer = HeaderFooterView<UIView>(.callback({
                    return self.FooterUIView
                }))
                footer.height = { 100 }
                return footer
            }()
        }
    }
    
    // 応募ボタンを押して募集者にメッセージを送る
    lazy var functions = Functions.functions()
    @IBAction func entryButtonTapped(_ sender: Any) {
        //プロフィールが作成済みかをチェック
        //プロフィールのUserdefaultsの有無で判断
        let defaults = UserDefaults.standard
        guard defaults.data(forKey: "profile") != nil else {
            // プロフィールが存在しない場合
            // UIAlertControllerクラスのインスタンスを生成
            let alert: UIAlertController = UIAlertController(title: "応募するにはプロフィールの作成が必要です", message: "マイページに移動しますか？", preferredStyle:  UIAlertControllerStyle.alert)
            // OKボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
                // マイページタブのViewControllerを取得する
                let viewController = self.tabBarController?.viewControllers![0] as! UINavigationController
                // マイページタブを選択済みにする
                self.tabBarController?.selectedViewController = viewController
                return
            })
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                //　アラートを閉じる
                alert.dismiss(animated: true, completion: nil)
                return
            })
            // UIAlertControllerにActionを追加
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            // Alertを表示
            present(alert, animated: true, completion: nil)
            return
        }
        //プロフィールが作成済みの場合
        print("Profile exists")
        let postID = self.postDoc.data()["postUser"] as! String
        // 二重応募になっていないかチェック
        if checkApplyHistoryArray(postID: postID) {
            // 二重応募でない場合
            // アラートを出す前にtabbarを非表示にする
            self.tabBarController?.tabBar.isHidden = true
            // ポップアップを出して応募メッセージ入力フォーマットを出す
            // 次のビューのインスタンスを生成し値を渡す。
            let secondView = ApplyAlertViewController()
            secondView.postID = postID
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let next = storyboard.instantiateViewController(withIdentifier: "ApplyAlert") as! ApplyAlertViewController
            next.postID = postID
            self.present(next,animated: true, completion: nil)
        } else { // 二重応募の場合
            //  UIAlertControllerクラスのインスタンスを生成
            let alert: UIAlertController = UIAlertController(title: "このチームには応募済みです", message: "", preferredStyle:  UIAlertControllerStyle.alert)
            // OKボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
                //　アラートを閉じる
                alert.dismiss(animated: true, completion: nil)
                return
            })
            // UIAlertControllerにActionを追加
            alert.addAction(defaultAction)
            // Alertを表示
            present(alert, animated: true, completion: nil)
        }
    }

    // 二重応募になっていないかチェック
    // 二重応募の場合はfalseを返す
    func checkApplyHistoryArray(postID: String) -> Bool{
        var StubApplyHistory:[String] = []
        let defaults = UserDefaults.standard
        // 今までの応募履歴を取得
        if defaults.value(forKey: "ApplyHistory") != nil {
            StubApplyHistory = defaults.value(forKey: "ApplyHistory") as! [String]
            // 応募履歴に応募しようとしている投稿者IDが含まれる場合
            if StubApplyHistory.contains(postID) {
                return false
            } else { //　応募履歴に応募しようとしている投稿者IDが含まれない場合
                return true
            }
        } else { //応募履歴がない場合
            return true
        }
    }
    
    //Set型の中身を単独のStingにまとめて返す
    func ArraytoSting(array: Array<String>) -> String?{
        if array.isEmpty{
            return nil
        } else {
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
