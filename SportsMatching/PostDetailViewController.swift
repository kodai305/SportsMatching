//
//  ApplyDetailViewController.swift
//  SportsMatching
//
//  Created by user on 2018/09/12.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import Foundation
import FirebaseFirestore
import UIKit
import Eureka

class PostDetailViewController: BaseFormViewController {
    
    // 募集履歴と応募履歴のどちらから来たかを管理するFlag
    var fromRecruiteFlag = 0
    var fromSearchFlag = 0
    
    // チャット画面で取得したDocumentを受け取る
    var GottenDoc:DocumentSnapshot!
    
    // チャット画面で取得した画像を受け取る
    var GottenUIImage:UIImage!
    
    // ヘッダー用
    let HeaderImageView = UIImageView()
    let HeaderUIView = UIView()
    
    @IBOutlet weak var BackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //表示する画像とボタンの位置を設定
        HeaderUIView.center.x = self.view.center.x
        
        HeaderImageView.image = self.GottenUIImage
        HeaderImageView.frame.size = CGSize(width: 200, height: 200)
        HeaderImageView.frame.origin.y = 10
        HeaderImageView.center.x = HeaderUIView.center.x
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        HeaderImageView.contentMode = UIViewContentMode.scaleAspectFit
        HeaderUIView.addSubview(HeaderImageView)
        
        // 上部に画像とボタンを設定
        form +++ Section(){ section in
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    return self.HeaderUIView
                }))
                header.height = { 210 }
                return header
            }()
        }
        
        //　募集履歴から遷移してきた場合
        //　募集者のプロフィールを表示
        if fromRecruiteFlag == 1 && fromSearchFlag == 0 {
            self.form +++ Section(header: "ユーザー情報", footer: "")
                <<< TextRow("UserName") {
                    $0.title = "ユーザー名"
                    $0.value = GottenDoc["userName"] as? String
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("Gender") {
                    $0.title = "性別"
                    $0.value = GottenDoc["gender"] as? String
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("Age") {
                    $0.title = "年代"
                    $0.value = GottenDoc["age"] as? String
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("Level") {
                    $0.title = "バスケットの経験"
                    $0.value = GottenDoc["level"] as? String
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextAreaRow("Comments") {
                    $0.value = GottenDoc["comments"] as? String
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
        } else if fromRecruiteFlag == 0 && fromSearchFlag == 1 {
            //　応募履歴から遷移してきた場合
            //　応募した投稿の内容を表示
            self.form +++ Section(header: "投稿の詳細", footer: "")
                <<< TextRow("TeamName") {
                    $0.title = "チーム名"
                    $0.value = GottenDoc["teamName"] as? String
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("Category") {
                    $0.title = "カテゴリ"
                    $0.value = GottenDoc["category"] as? String
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("Prefecture") {
                    $0.title = "都道府県"
                    $0.value = GottenDoc["prefecture"] as? String
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("Place"){
                    $0.title = "活動場所"
                    $0.value = GottenDoc["place"] as? String
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("ApplyGender") {
                    $0.title = "募集性別"
                    $0.value = GottenDoc["applyGender"] as? String
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("Timezone") {
                    $0.title = "活動時間帯"
                    $0.value = self.ArraytoSting(array: GottenDoc["timezone"] as! Array<String>)
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("Position") {
                    $0.title = "募集ポジション"
                    $0.value = self.ArraytoSting(array: GottenDoc["position"] as! Array<String>)
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("ApplyLevel") {
                    $0.title = "参加可能なレベル"
                    $0.value = self.ArraytoSting(array: GottenDoc["applyLevel"] as! Array<String>)
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("GenderRatio") {
                    $0.title = "チーム構成"
                    $0.value = GottenDoc["genderRatio"] as? String
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("TeamLevel") {
                    $0.title = "チームのレベル"
                    $0.value = GottenDoc["teamLevel"] as? String
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("NumMembers"){
                    $0.title = "チームの人数"
                    $0.value = GottenDoc["numMembers"] as! Int == 0 ? nil: String(GottenDoc["numMembers"] as! Int)
                    $0.baseCell.isUserInteractionEnabled = false
                }
                
                <<< TextRow("Day") {
                    $0.title = "開催曜日"
                    $0.value = self.ArraytoSting(array: GottenDoc["day"] as! Array<String>)
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextRow("MainAge") {
                    $0.title = "メンバー年齢"
                    $0.value = self.ArraytoSting(array: GottenDoc["mainAge"] as! Array<String>)
                    $0.baseCell.isUserInteractionEnabled = false
                }
                <<< TextAreaRow("Comments") {
                    $0.value = GottenDoc["comments"] as? String
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
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func BackButtonTapped(sender : AnyObject) {
        let storyboard: UIStoryboard = self.storyboard!
        let mailView = storyboard.instantiateViewController(withIdentifier: "MailView") as! MailViewController
        //  再度ボタンを押す場合のためにFlagの値を返す
        mailView.fromRecruiteFlag = self.fromRecruiteFlag
        mailView.fromSearchFlag = self.fromSearchFlag
        dismiss(animated: true, completion: nil)
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
