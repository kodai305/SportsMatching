//
//  SearchViewController.swift
//  SportsMatching
//
//  Created by user on 2018/08/09.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import FirebaseFirestore
import SVProgressHUD

class SearchViewController: BaseFormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section(header: "検索条件", footer: "すべての項目を入力してください")
            <<< ActionSheetRow<String>("Category") {
                $0.title = "カテゴリ"
                $0.selectorTitle = "チームのカテゴリー"
                $0.options = ["ミニバス", "ジュニア", "社会人サークル", "クラブチーム"]
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            <<< PushRow<String>("Prefecture") {
                $0.title = "都道府県"
                $0.options = ["北海道", "青森県", "岩手県", "宮城県", "秋田県",
                              "山形県", "福島県", "茨城県", "栃木県", "群馬県",
                              "埼玉県", "千葉県", "東京都", "神奈川県", "新潟県",
                              "富山県", "石川県", "福井県", "山梨県", "長野県",
                              "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県",
                              "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県",
                              "鳥取県", "島根県", "岡山県", "広島県", "山口県",
                              "徳島県", "香川県", "愛媛県", "高知県", "福岡県",
                              "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県",
                              "鹿児島県", "沖縄県"]
                $0.selectorTitle = "都道府県"
                }.onPresent { from, to in
                    to.dismissOnSelection = false
                    to.dismissOnChange = true
                    to.sectionKeyForValue = { option in
                        switch option {
                        case "北海道", "青森県", "岩手県", "宮城県", "秋田県","山形県", "福島県": return "1北海道・東北"
                        case "茨城県", "栃木県", "群馬県","埼玉県", "千葉県", "東京都", "神奈川県": return "2関東"
                        case "新潟県","富山県", "石川県", "福井県", "山梨県", "長野県","岐阜県", "静岡県", "愛知県": return "3中部"
                        case "三重県", "滋賀県","京都府", "大阪府", "兵庫県", "奈良県", "和歌山県": return "4関西"
                        case "鳥取県", "島根県", "岡山県", "広島県", "山口県": return "5中国"
                        case "徳島県", "香川県", "愛媛県", "高知県": return "6四国"
                        case "福岡県","佐賀県", "長崎県", "熊本県", "大分県", "宮崎県","鹿児島県", "沖縄県": return "7九州・沖縄"
                        default: return ""
                        }
                    }
            }
            <<< MultipleSelectorRow<String>("Day") {
                $0.title = "参加希望曜日"
                $0.selectorTitle = "参加したい曜日"
                $0.options = ["いつでも","月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"]
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "選択完了", style: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
                    to.sectionKeyForValue = { option in
                        switch option {
                        case "いつでも","月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日": return "複数選択可能"
                        default: return ""
                        }
                    }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toResultViewController" {
            let nextView:SearchResultViewController = segue.destination as! SearchResultViewController
            // タグ設定済みの全てのRowの値を取得
            let values = form.values()
            // Rowの値を取得して遷移先の変数に設定
            nextView.category = values["Category"] as? String
            nextView.prefecture = values["Prefecture"] as? String
            // 「いつでも」が選択されている場合、全ての曜日を検索条件として渡す
            if Array(values["Day"] as! Set<String>).contains("いつでも"){
                nextView.day = ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"]
            } else {
                nextView.day = Array(values["Day"] as! Set<String>)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toResultViewController" {
            // タグ設定済みの全てのRowの値を取得
            let values = form.values()
            // 選択されていない項目がある場合、遷移しないでアラートを出す
            if values["Category"].unsafelyUnwrapped == nil {
                SVProgressHUD.showError(withStatus: "カテゴリを選択して下さい")
                return false
            } else if values["Prefecture"].unsafelyUnwrapped == nil {
                SVProgressHUD.showError(withStatus: "都道府県を選択して下さい")
                return false
            } else if values["Day"].unsafelyUnwrapped == nil {
                SVProgressHUD.showError(withStatus: "参加希望曜日を選択して下さい")
                return false
            }
            // 検索条件が全て選択されている時、遷移
            SVProgressHUD.show(withStatus: "検索中")
            return true
        }
        return false
    }
    
    //　曜日選択Viewの右上のボタンの処理
    @objc func daySelectorDone(_ item:UIBarButtonItem) {
        // 選択された曜日を取得
        let selectedDays = Array(form.values()["Day"] as! Set<String>)
        // 「いつでも」といずれかの曜日が同時に選択されたいる場合アラートを出す
        if selectedDays.contains("いつでも"){
            // いずれかの曜日が選ばれた場合にtrue(条件文が汚い…)
            if selectedDays.contains("月曜日") || selectedDays.contains("火曜日") || selectedDays.contains("水曜日") || selectedDays.contains("木曜日") || selectedDays.contains("金曜日") || selectedDays.contains("土曜日") || selectedDays.contains("日曜日") {
                let alert: UIAlertController = UIAlertController(title: "「いつでも」は単独で使用して下さい", message: "", preferredStyle:  UIAlertControllerStyle.alert)
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
