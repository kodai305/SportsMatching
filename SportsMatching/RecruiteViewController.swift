//
//  RecuruiteViewController.swift
//  
//
//  Created by 高木広大 on 2018/08/05.
//

import UIKit
import Eureka
import ImageRow
import FirebaseFirestore

class RecruiteViewController: FormViewController {

    
    // 選択されたイメージ格納用
    var selectedImg = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section(header: "必須項目", footer: "すべての項目を入力してください")
            <<< NameRow("teamName") {
                $0.title = "チーム名"
                $0.placeholder = "チーム名/サークル名"
            }
            <<< TextRow("events") {
                $0.title = "種目名"
                $0.placeholder = "プルダウンにしたい"
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
                $0.value = "都道府県名"
                $0.selectorTitle = "都道府県名"
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
            <<< TextRow("place"){
                $0.title = "活動場所"
                $0.placeholder = "体育館など"
            }
            <<< TextRow("time"){
                $0.title = "活動時間"
                $0.placeholder = "時間、頻度を入力"
        }
        
        form +++ Section(header: "任意項目", footer: "応募者が参考にするため、なるべく入力してください")
            <<< TextRow("recruiteAge") {
                $0.title = "募集年齢"
                $0.placeholder = "例：18歳から30歳まで"
            }
            <<< TextRow("memberInfo") {
                $0.title = "メンバー構成"
                $0.placeholder = "例：20歳男子中心"
            }
            <<< TextRow("memberAge"){
                $0.title = "平均年齢"
                $0.placeholder = "例：20台後半中心"
            }
            <<< ImageRow() {
                $0.title = "活動風景画像"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                $0.value = UIImage(named: "activeImage")
                $0.clearAction = .yes(style: .destructive)
                $0.onChange { [unowned self] row in
                            self.selectedImg = row.value!
                }
        }
        
        form +++ Section(header: "募集内容/連絡事項", footer: "不特定多数の方が見るため連絡先の掲載はお控えください")
            <<< TextAreaRow("freeWrite") {
                $0.placeholder = "自由記述"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
        }
        
        // Do any additional setup after loading the view.
    }

    @IBAction func postButton(_ sender: Any) {
        // XXX: 投稿ボタンを押した際の処理を実装する
        
        // XXX: 必須項目の入力チェック
        
        // タグ設定済みの全てのRowの値を取得
        let values = form.values()
        let db = Firestore.firestore()
        
        //チーム名＋都道県名をIDにする（仮）
        let ID:String = (values["teamName"] as! String) + (values["prefecture"] as! String)

        db.collection(values["events"] as! String).document(ID).setData([
            "teamName": values["teamName"] as! String,
            "prefecture": values["prefecture"] as! String
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
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
