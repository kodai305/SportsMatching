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
        form +++ Section(header: "必須項目", footer: "すべての項目を入力してください")
            <<< ActionSheetRow<String>("category") {
                $0.title = "カテゴリ"
                $0.selectorTitle = "チームのカテゴリーを選択"
                $0.options = ["ミニバス", "ジュニア", "社会人", "クラブチーム"]
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            <<< PushRow<String>("prefecture") {
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
                    to.dismissOnChange = false
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

        // fcmTokenをuser-defaultに保存
        let defaults = UserDefaults.standard
        let data = defaults.string(forKey: "background")
        print("data:")
        print(data as Any)
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
            nextView.category = values["category"] as! String
            nextView.prefecture = values["prefecture"] as! String
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toResultViewController" {
            // タグ設定済みの全てのRowの値を取得
            let values = form.values()
            if values["category"].unsafelyUnwrapped == nil {
                SVProgressHUD.showError(withStatus: "種目名を選択して下さい")
                return false
            }
            if values["prefecture"].unsafelyUnwrapped == nil {
                SVProgressHUD.showError(withStatus: "都道府県を選択して下さい")
                return false
            }
            return true
        }
        return false
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
