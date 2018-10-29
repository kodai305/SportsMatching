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
import FirebaseStorage
import SVProgressHUD

class EditRecruiteViewController: BaseFormViewController {

    // UIDの読み取り
    let MyUID: String = UserDefaults.standard.string(forKey: "UID")!
    //初回投稿時間を保存
    var InitialPostedTime:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Userdefalutsから投稿詳細を取得
        var savedPostDetail = PostDetail()
        let defaults = UserDefaults.standard
        //投稿がない場合アラートを出す
        guard let data = defaults.data(forKey: "recruite") else {
            SVProgressHUD.showError(withStatus: "投稿がありません")
            return
        }
        savedPostDetail = try! JSONDecoder().decode(PostDetail.self, from: data)
        InitialPostedTime = savedPostDetail.PostedTime
        
        // 投稿済みの内容をフォームに反映する
        // 複数選択可能な項目はArrayで保存してあるデータをSetに変換する
        self.form +++
            Section(header: "必須項目", footer: "すべての項目を入力してください")
            <<< TextRow("TeamName") {
                $0.title = "チーム名"
                $0.placeholder = "チーム名/サークル名"
                $0.value = savedPostDetail.TeamName
            }
            <<< ActionSheetRow<String>("Category") {
                $0.title = "カテゴリ"
                $0.selectorTitle = "チームのカテゴリーを選択"
                $0.options = ["ミニバス", "ジュニア", "社会人", "クラブチーム"]
                $0.value = savedPostDetail.Category
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
                $0.selectorTitle = "都道府県名"
                $0.value = savedPostDetail.Prefecture
                }.onPresent { from, to in
                    to.dismissOnSelection = false
                    to.dismissOnChange = false
                    to.sectionKeyForValue = { option in
                        switch option {
                        case "北海道", "青森県", "岩手県", "宮城県", "秋田県","山形県", "福島県": return "1. 北海道・東北"
                        case "茨城県", "栃木県", "群馬県","埼玉県", "千葉県", "東京都", "神奈川県": return "2. 関東"
                        case "新潟県","富山県", "石川県", "福井県", "山梨県", "長野県","岐阜県", "静岡県", "愛知県": return "3. 中部"
                        case "三重県", "滋賀県","京都府", "大阪府", "兵庫県", "奈良県", "和歌山県": return "4. 関西"
                        case "鳥取県", "島根県", "岡山県", "広島県", "山口県": return "5. 中国"
                        case "徳島県", "香川県", "愛媛県", "高知県": return "6. 四国"
                        case "福岡県","佐賀県", "長崎県", "熊本県", "大分県", "宮崎県","鹿児島県", "沖縄県": return "7. 九州・沖縄"
                        default: return ""
                        }
                    }
            }
            <<< TextRow("Place"){
                $0.title = "活動場所"
                $0.placeholder = "体育館名など"
                $0.value = savedPostDetail.Place
            }
            <<< ActionSheetRow<String>("ApplyGender") {
                $0.title = "募集性別"
                $0.selectorTitle = "募集する性別を選択"
                $0.options = ["不問", "男性", "女性"]
                $0.value = savedPostDetail.ApplyGender
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            <<< MultipleSelectorRow<String>("Day") {
                $0.title = "開催曜日"
                $0.selectorTitle = "主に開催している曜日を選択"
                $0.options = ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"]
                $0.value = (savedPostDetail.Day?.isEmpty)! ? nil : Set(savedPostDetail.Day!)
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< ImageRow("Image") {
                $0.title = "活動風景画像"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                $0.value = UIImage(data: savedPostDetail.Image)
                $0.clearAction = .yes(style: .destructive)
        }
        
        self.form +++ Section(header: "任意項目", footer: "応募者が参考にするため、なるべく入力してください")
            <<< MultipleSelectorRow<String>("Position") {
                $0.title = "募集ポジション"
                $0.selectorTitle = "募集するポジションを選択"
                $0.options = ["どこでも","ガード", "フォワード", "センター", "マネジャー"]
                $0.value = (savedPostDetail.Position?.isEmpty)! ? nil : Set(savedPostDetail.Position!)
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<String>("ApplyLevel") {
                $0.title = "参加可能なレベル"
                $0.selectorTitle = "参加可能なレベルを選択"
                $0.options = ["未経験", "初心者", "上級者"]
                $0.value = (savedPostDetail.ApplyLevel?.isEmpty)! ? nil : Set(savedPostDetail.ApplyLevel!)
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< ActionSheetRow<String>("GenderRatio") {
                $0.title = "チーム構成"
                $0.selectorTitle = "一番近い男女比を選択"
                $0.options = ["ミックス", "男性のみ", "女性のみ"]
                $0.value = savedPostDetail.GenderRatio == "" ? nil : savedPostDetail.GenderRatio
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            <<< ActionSheetRow<String>("TeamLevel") {
                $0.title = "チームのレベル"
                $0.selectorTitle = "一番近いチームレベルを選択"
                $0.options = ["未経験中心", "初心者中心", "上級者中心"]
                $0.value = savedPostDetail.TeamLevel == "" ? nil : savedPostDetail.TeamLevel
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            <<< IntRow("NumMembers"){
                $0.title = "チームの人数"
                $0.placeholder = "1回あたりの目安"
                $0.value = savedPostDetail.NumMembers == 0 ? nil : savedPostDetail.NumMembers
            }
            
            <<< MultipleSelectorRow<String>("Timezone") {
                $0.title = "活動時間帯"
                $0.selectorTitle = "活動時間帯(複数選択可)"
                $0.options = ["午前", "午後", "夜"]
                $0.value = (savedPostDetail.Timezone?.isEmpty)! ? nil : Set(savedPostDetail.Timezone!)
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<String>("MainAge") {
                $0.title = "メンバー年齢"
                $0.selectorTitle = "メンバーの主な年代を選択(複数可)"
                $0.options = ["10代", "20代", "30代", "40代", "50代", "60代以上"]
                $0.value = (savedPostDetail.MainAge?.isEmpty)! ? nil : Set(savedPostDetail.MainAge!)
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
        }
        
        self.form +++ Section(header: "募集内容/連絡事項", footer: "不特定多数の方が見るため連絡先の掲載はお控えください")
            <<< TextAreaRow("Comments") {
                $0.placeholder = "自由記述"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                $0.value = savedPostDetail.Comments == "" ? nil : savedPostDetail.Comments
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func completeButton(_ sender: Any) {
        SVProgressHUD.show(withStatus: "投稿中")
        // タグ設定済みの全てのRowの値を取得
        let Values = form.values()
        //必須項目が入力済みか確認
        if Values["TeamName"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "チーム名を入力して下さい")
            return
        } else if Values["Category"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "カテゴリーを選択して下さい")
            return
        } else if Values["Prefecture"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "都道府県を選択して下さい")
            return
        } else if Values["Place"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "活動場所を入力して下さい")
            return
        } else if Values["ApplyGender"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "性別を選択して下さい")
            return
        } else if Values["Day"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "活動曜日を選択して下さい")
            return
        } else if Values["Image"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "活動画像を選択して下さい")
            return
        }
        
        //時刻を取得(年月日、時分)
        let f = DateFormatter()
        f.timeStyle = .long
        f.dateStyle = .short
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        
        //画像セルから画像を取得
        let SelectedImgae = Values["Image"] as! UIImage
        
        //Userdefaultsに保存
        savePostDetailtoUserdefautls(postedTime: InitialPostedTime, updateTime: f.string(from: now), myUID: MyUID, values: Values, selectedImgae: SelectedImgae)
        
        //FireStoreに投稿データを保存
        //複数選択可能な項目はSetからArrayへの変換を行う
        let db = Firestore.firestore()
        db.collection("posts").document(MyUID).setData([
            "postedTime"  : InitialPostedTime,
            "updateTime"  : f.string(from: now),
            "postUser"    : MyUID,
            "teamName"    : Values["TeamName"] as! String,
            "category"    : Values["Category"] as! String,
            "prefecture"  : Values["Prefecture"] as! String,
            "place"       : Values["Place"] as! String,
            "applyGender" : Values["ApplyGender"] as! String,
            "day"         : Array(Values["Day"] as! Set<String>),
            "position"    : Values["Position"].unsafelyUnwrapped == nil ? Array() : Array(Values["Position"] as! Set<String>),
            "applyLevel"  : Values["ApplyLevel"].unsafelyUnwrapped == nil ? Array() : Array(Values["ApplyLevel"] as! Set<String>),
            "genderRatio" : Values["GenderRatio"].unsafelyUnwrapped == nil ? "" : Values["GenderRatio"] as! String,
            "teamLevel"   : Values["TeamLevel"].unsafelyUnwrapped == nil ? "" : Values["TeamLevel"] as! String,
            "numMembers"  : Values["NumMembers"].unsafelyUnwrapped == nil ? 0 : Values["NumMembers"] as! Int,
            "timezone"    : Values["Timezone"].unsafelyUnwrapped == nil ? Array() : Array(Values["Timezone"] as! Set<String>),
            "mainAge"     : Values["MainAge"].unsafelyUnwrapped == nil ? Array() : Array(Values["MainAge"] as! Set<String>),
            "comments"    : Values["Comments"].unsafelyUnwrapped == nil ? "" : Values["Comments"] as! String
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        // FirebaseStorageに画像を保存
        // 保存が成功するとtrueが返ってくる
        if saveImagetoFirebaseStorage(directory: "post", myUID: MyUID, selectedImgae: SelectedImgae) {
        SVProgressHUD.showSuccess(withStatus: "投稿成功")
        // 新規投稿と投稿編集のボタンがある画面に戻る
        self.navigationController?.popViewController(animated: false)
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
