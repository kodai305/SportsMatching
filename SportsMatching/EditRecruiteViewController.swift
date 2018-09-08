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
    
    // 選択されたイメージ格納用
    var selectedImg = UIImage()
    // UIDの読み取り
    let myUID: String = UserDefaults.standard.string(forKey: "UID")!
    //初回投稿時間を保存
    var InitialPostedTime:String!
    // 応募詳細の構造体
    struct RecruiteDetail: Codable {
        var PostedTime  : String? = nil
        var UpdateTime  : String? = nil
        var PostUser    : String? = nil
        var TeamName    : String? = nil
        var Category    : String? = nil
        var Prefecture  : String? = nil
        var Place       : String? = nil
        var ApplyGender : String? = nil
        var Timezone    : Array<String>? = nil
        var Image       : Data = Data()
        var Position    : Array<String>? = nil
        var ApplyLevel  : Array<String>? = nil
        var GenderRatio : String? = nil
        var TeamLevel   : String? = nil
        var NumMembers  : Int? = nil
        var Day         : Array<String>? = nil
        var MainAge     : Array<String>? = nil
        var Comments    : String? = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Userdefalutsから投稿詳細を取得
        var savedRecruiteDetail = RecruiteDetail()
        let defaults = UserDefaults.standard
        //投稿がない場合アラートを出す
        guard let data = defaults.data(forKey: "recruite") else {
            SVProgressHUD.showError(withStatus: "投稿がありません")
            return
        }
        savedRecruiteDetail = try! JSONDecoder().decode(RecruiteDetail.self, from: data)
        InitialPostedTime = savedRecruiteDetail.PostedTime
        
        self.form +++
            Section(header: "必須項目", footer: "すべての項目を入力してください")
            <<< TextRow("TeamName") {
                $0.title = "チーム名"
                $0.placeholder = "チーム名/サークル名"
                $0.value = savedRecruiteDetail.TeamName
            }
            <<< ActionSheetRow<String>("Category") {
                $0.title = "カテゴリ"
                $0.selectorTitle = "チームのカテゴリーを選択"
                $0.options = ["ミニバス", "ジュニア", "社会人", "クラブチーム"]
                $0.value = savedRecruiteDetail.Category
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
                $0.value = savedRecruiteDetail.Prefecture
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
                $0.value = savedRecruiteDetail.Place
            }
            <<< ActionSheetRow<String>("ApplyGender") {
                $0.title = "募集性別"
                $0.selectorTitle = "募集する性別を選択"
                $0.options = ["不問", "男性", "女性"]
                $0.value = savedRecruiteDetail.ApplyGender
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            <<< MultipleSelectorRow<String>("Timezone") {
                $0.title = "活動時間帯"
                $0.selectorTitle = "活動時間帯(複数選択可)"
                $0.options = ["午前", "午後", "夜"]
                $0.value = Set(savedRecruiteDetail.Timezone!)
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< ImageRow("Image1") {
                $0.title = "活動風景画像"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                $0.value = UIImage(data: savedRecruiteDetail.Image)
                $0.clearAction = .yes(style: .destructive)
                $0.onChange { [unowned self] row in
                    self.selectedImg = row.value!
                }
        }
        
        self.form +++ Section(header: "任意項目", footer: "応募者が参考にするため、なるべく入力してください")
            <<< MultipleSelectorRow<String>("Position") {
                $0.title = "募集ポジション"
                $0.selectorTitle = "募集するポジションを選択"
                $0.options = ["どこでも","ガード", "フォワード", "センター", "マネジャー"]
                $0.value = savedRecruiteDetail.Position == nil ? nil : Set(savedRecruiteDetail.Position!)
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<String>("ApplyLevel") {
                $0.title = "参加可能なレベル"
                $0.selectorTitle = "参加可能なレベルを選択"
                $0.options = ["未経験", "初心者", "上級者"]
                $0.value = savedRecruiteDetail.ApplyLevel == nil ? nil : Set(savedRecruiteDetail.ApplyLevel!)
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< ActionSheetRow<String>("GenderRatio") {
                $0.title = "チーム構成"
                $0.selectorTitle = "一番近い男女比を選択"
                $0.options = ["ミックス", "男性のみ", "女性のみ"]
                $0.value = savedRecruiteDetail.GenderRatio
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            <<< ActionSheetRow<String>("TeamLevel") {
                $0.title = "チームのレベル"
                $0.selectorTitle = "一番近いチームレベルを選択"
                $0.options = ["未経験中心", "初心者中心", "上級者中心"]
                $0.value = savedRecruiteDetail.TeamLevel
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            <<< IntRow("NumMembers"){
                $0.title = "チームの人数"
                $0.placeholder = "1回あたりの目安"
                $0.value = savedRecruiteDetail.NumMembers
            }
            
            <<< MultipleSelectorRow<String>("Day") {
                $0.title = "開催曜日"
                $0.selectorTitle = "主に開催している曜日を選択"
                $0.options = ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"]
                $0.value = savedRecruiteDetail.Day == nil ? nil : Set(savedRecruiteDetail.Day!)
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<String>("MainAge") {
                $0.title = "メンバー年齢"
                $0.selectorTitle = "メンバーの主な年代を選択(複数可)"
                $0.options = ["10代", "20代", "30代", "40代", "50代", "60代以上"]
                $0.value = savedRecruiteDetail.MainAge == nil ? nil : Set(savedRecruiteDetail.MainAge!)
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
        }
        
        self.form +++ Section(header: "募集内容/連絡事項", footer: "不特定多数の方が見るため連絡先の掲載はお控えください")
            <<< TextAreaRow("Comments") {
                $0.placeholder = "自由記述"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                $0.value = savedRecruiteDetail.Comments
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func completeButton(_ sender: Any) {
        // タグ設定済みの全てのRowの値を取得
        let values = form.values()
        //必須項目が入力済みか確認
        if values["TeamName"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "チーム名を入力して下さい")
            return
        } else if values["Category"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "カテゴリーを選択して下さい")
            return
        } else if values["Prefecture"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "都道府県を選択して下さい")
            return
        } else if values["Place"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "活動場所を入力して下さい")
            return
        } else if values["ApplyGender"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "性別を選択して下さい")
            return
        } else if values["Timezone"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "活動時間帯を選択して下さい")
            return
        } else if values["Image1"].unsafelyUnwrapped == nil {
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
        let UIImgae = values["Image1"] as! UIImage
        
        //Userdefaultsに保存
        let defaults = UserDefaults.standard
        var NewRecruitDetaile = RecruiteDetail()
        NewRecruitDetaile.PostedTime = InitialPostedTime
        NewRecruitDetaile.UpdateTime = f.string(from: now)
        NewRecruitDetaile.PostUser = myUID
        NewRecruitDetaile.TeamName = values["TeamName"] as? String
        NewRecruitDetaile.Category = values["Category"] as? String
        NewRecruitDetaile.Prefecture = values["Prefecture"] as? String
        NewRecruitDetaile.Place = values["Place"] as? String
        NewRecruitDetaile.ApplyGender = values["ApplyGender"] as? String
        NewRecruitDetaile.Timezone = values["Timezone"].unsafelyUnwrapped == nil ? nil : Array(values["Timezone"] as! Set<String>)
        NewRecruitDetaile.Image = UIImageJPEGRepresentation(UIImgae, 0.5)!
        NewRecruitDetaile.Position = values["Position"].unsafelyUnwrapped == nil ? nil : Array(values["Position"] as! Set<String>)
        NewRecruitDetaile.ApplyLevel = values["ApplyLevel"].unsafelyUnwrapped == nil ? nil : Array(values["ApplyLevel"] as! Set<String>)
        NewRecruitDetaile.GenderRatio = values["GenderRatio"] as? String
        NewRecruitDetaile.TeamLevel = values["TeamLevel"] as? String
        NewRecruitDetaile.NumMembers = values["NumMembers"] as? Int
        NewRecruitDetaile.Day = values["Day"].unsafelyUnwrapped == nil ? nil : Array(values["Day"] as! Set<String>)
        NewRecruitDetaile.MainAge = values["MainAge"].unsafelyUnwrapped == nil ? nil : Array(values["MainAge"] as! Set<String>)
        NewRecruitDetaile.Comments = values["Comments"] as? String
        let data = try? JSONEncoder().encode(NewRecruitDetaile)
        defaults.set(data ,forKey: "recruite")
        
        //FireStoreに投稿データを保存
        //複数選択可能な項目はSetからArrayへの変換を行う
        let db = Firestore.firestore()
        db.collection("posts").document(myUID).setData([
            "postedTime"  : InitialPostedTime,
            "updateTime"  : f.string(from: now),
            "postUser"    : myUID,
            "teamName"    : values["TeamName"] as! String,
            "category"    : values["Category"] as! String,
            "prefecture"  : values["Prefecture"] as! String,
            "place"       : values["Place"] as! String,
            "applyGender" : values["ApplyGender"] as! String,
            "timezone"    : Array(values["Timezone"] as! Set<String>),  //ここまでは必須項目
            "position"    : values["Position"].unsafelyUnwrapped == nil ? "" : Array(values["Position"] as! Set<String>),
            "applyLevel"  : values["ApplyLevel"].unsafelyUnwrapped == nil ? "" : Array(values["ApplyLevel"] as! Set<String>),
            "genderRatio" : values["GenderRatio"].unsafelyUnwrapped == nil ? "" : values["GenderRatio"] as! String,
            "teamLevel"   : values["TeamLevel"].unsafelyUnwrapped == nil ? "" : values["TeamLevel"] as! String,
            "numMembers"  : values["NumMembers"].unsafelyUnwrapped == nil ? "" : values["NumMembers"] as! Int,
            "day"         : values["Day"].unsafelyUnwrapped == nil ? "" : Array(values["Day"] as! Set<String>),
            "mainAge"     : values["MainAge"].unsafelyUnwrapped == nil ? "" : Array(values["MainAge"] as! Set<String>),
            "comments"    : values["Comments"].unsafelyUnwrapped == nil ? "" : values["Comments"] as! String
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        //画像セルから画像を取得
        let UIImgae1 = values["Image1"] as! UIImage
        var ImageShrinkRatio:CGFloat = 1.0
        //Firebase Storageの準備
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // UIImageJPEGRepresentationでUIImageをNSDataに変換して格納
        if var data = UIImageJPEGRepresentation(UIImgae1, ImageShrinkRatio){
            //画像のファイルサイズが1024*1024/2bytes以下になるまで縮小係数を調整
            while data.count > 1024 * 1024 / 2{
                ImageShrinkRatio = ImageShrinkRatio - 0.1
                data = UIImageJPEGRepresentation(UIImgae1, ImageShrinkRatio)!
            }
            //とりあえずUIDのディレクトリを作成し、その下に画像を保存
            let reference = storageRef.child(myUID + "/post" + "/image1" + ".jpg")
            reference.putData(data, metadata: nil, completion: { metaData, error in
                print(metaData as Any)
                print(error as Any)
            })
            SVProgressHUD.showSuccess(withStatus: "投稿成功")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //複数選択するための関数
    @objc func multipleSelectorDone(_ item:UIBarButtonItem) {
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