//
//  CreateProfileViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/19.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD

class CreateProfileViewController: FormViewController {
    // UIDの読み取り
    let myUID: String = UserDefaults.standard.string(forKey: "UID")!
    // fcmTokenの読み取り
    let myFcmToken: String = UserDefaults.standard.string(forKey: "fcmToken")!
   
    // 選択されたイメージ格納用
    var selectedImg = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Userdefalutsからプロフィールを取得
        var savedProfile = Profile()
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "profile"){
            savedProfile = try! JSONDecoder().decode(Profile.self, from: data)
        }
        
        // 登録フォーム
        // プロフィールが作成済みの場合はその情報をvalueに入れる
        self.form +++ Section(header: "ユーザー情報", footer: "すべての項目を入力してください")
            <<< TextRow("UserName") {
                $0.title = "ユーザー名"
                $0.placeholder = "相手に表示される名前"
                $0.value = savedProfile.UserName
            }
            <<< ActionSheetRow<String>("Gender") {
                $0.title = "性別"
                $0.selectorTitle = "性別を選択"
                $0.options = ["男性", "女性"]
                $0.value = savedProfile.Gender
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            <<< ActionSheetRow<String>("Age") {
                $0.title = "年代"
                $0.selectorTitle = "あなたの年代を選択"
                $0.options = ["10代", "20代", "30代", "40代", "50代", "60代以上"]
                $0.value = savedProfile.Age
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            <<< ActionSheetRow<String>("Level") {
                $0.title = "バスケットの経験"
                $0.selectorTitle = "バスケットの経験を選択"
                $0.options = ["未経験", "初心者", "上級者"]
                $0.value = savedProfile.Level
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }
            <<< ImageRow("Image") {
                $0.title = "公開される画像"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                $0.value = savedProfile.Image == Data() ? nil : UIImage(data: savedProfile.Image)
                $0.clearAction = .yes(style: .destructive)
                $0.onChange { [unowned self] row in
                    self.selectedImg = row.value!
            }
        }
            
        self.form +++ Section(header: "自由記述", footer: "不特定多数の方が見るため連絡先の掲載はお控えください")
            <<< TextAreaRow("Comments") {
                $0.placeholder = "自由記述"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                $0.value = savedProfile.Comments
            }
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func saveUserProfileButtonPushed(_ sender: Any) {
        // タグ設定済みの全てのRowの値を取得
        let values = form.values()
        // 入力値の確認
        if values["UserName"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "ユーザー名を入力して下さい")
            return
        }else if values["Gender"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "性別を入力して下さい")
            return
        }else if values["Age"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "年代を入力して下さい")
            return
        }else if values["Level"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "競技レベルを入力して下さい")
            return
        }else if values["Image"].unsafelyUnwrapped == nil {
            SVProgressHUD.showError(withStatus: "画像を入力して下さい")
            return
        }
        
        //画像セルから画像を取得
        let UIImgae = values["Image"] as! UIImage
        
        // profile構造体をつくってUser-defaultに保存
        var MyProfile = Profile()
        MyProfile.UserName = values["UserName"] as? String
        MyProfile.Gender = values["Gender"] as? String
        MyProfile.Age = values["Age"] as? String
        MyProfile.Level = values["Level"] as? String
        // サイズを半分(0.5倍)してNSDataに変換
        MyProfile.Image =  UIImageJPEGRepresentation(UIImgae, 0.5)!
        // コメントは未入力の可能性があるのでnilチェック
        MyProfile.Comments = values["Comments"].unsafelyUnwrapped == nil ? "" : values["Comments"] as! String
        let data = try? JSONEncoder().encode(MyProfile)
        let defaults = UserDefaults.standard
        defaults.set(data ,forKey: "profile")
        
        //時刻を取得(年月日、時分)
        let f = DateFormatter()
        f.timeStyle = .long
        f.dateStyle = .short
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        
        // プロフィールをfirestoreに保存
        let db = Firestore.firestore()
        db.collection("users").document(myUID).setData([
            "postedTime"  : f.string(from: now),
            "userName"    : values["UserName"] as! String,
            "gender"      : values["Gender"] as! String,
            "age"         : values["Age"] as! String,
            "level"       : values["Level"] as! String,
            "comments"    : values["Comments"].unsafelyUnwrapped == nil ? "" : values["Comments"] as! String,
            "fcmToken"    : myFcmToken
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        var ImageShrinkRatio:CGFloat = 1.0
        //Firebase Storageの準備
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // UIImageJPEGRepresentationでUIImageをNSDataに変換して格納
        if var data = UIImageJPEGRepresentation(UIImgae, ImageShrinkRatio){
            //画像のファイルサイズが1024*1024bytes以下になるまで縮小係数を調整
            while data.count > 1024 * 1024{
                ImageShrinkRatio = ImageShrinkRatio - 0.1
                data = UIImageJPEGRepresentation(UIImgae, ImageShrinkRatio)!
            }
            //とりあえずUIDのディレクトリを作成し、その下に画像を保存
            let reference = storageRef.child(myUID + "/profile" + "/image" + ".jpg")
            reference.putData(data, metadata: nil, completion: { metaData, error in
                print(metaData as Any)
                print(error as Any)
            })
            SVProgressHUD.showSuccess(withStatus: "登録成功")
            // TODO: 1秒待ったほうがいいかも？
            // MyPageへ遷移する
            self.show((self.storyboard?.instantiateViewController(withIdentifier: "MyPage"))!,sender: true)
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
