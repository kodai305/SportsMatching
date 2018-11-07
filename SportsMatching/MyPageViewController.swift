//
//  MyPageViewController.swift
//  SportsMatching
//
//  Created by user on 2018/08/15.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import Eureka
import FirebaseFirestore

import FirebaseAuth
import FirebaseUI

import MessageUI

class MyPageViewController: BaseFormViewController,FUIAuthDelegate,MFMailComposeViewControllerDelegate {
    
    let HeaderImageView = UIImageView()
    let HeaderUIView = UIView()
    
    @IBOutlet weak var EditProfileButton: UIButton!
    
    var CurrentUser:User!
    
    //ログアウトボタン(開発用、本番では消す)
    @IBOutlet weak var LogOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Userdefalutsからプロフィールを取得
        var savedProfile = Profile()
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "profile"){
            savedProfile = try! JSONDecoder().decode(Profile.self, from: data)
            HeaderImageView.image = UIImage(data: savedProfile.Image)
            self.EditProfileButton.setTitle("プロフィールを編集", for: .normal)
        } else { //プロフィール作成されてない場合
            savedProfile.UserName = nil
            savedProfile.Gender = nil
            savedProfile.Age = nil
            savedProfile.Level = nil
            HeaderImageView.image = UIImage(named: "profilealert")
            self.EditProfileButton.setTitle("プロフィールを作成", for: .normal)
        }
        
        //表示する画像とボタンの位置を設定
        HeaderUIView.frame.size.width = 200
        HeaderUIView.center.x = self.view.center.x
        HeaderImageView.frame.size = CGSize(width: 200, height: 200)
        HeaderImageView.frame.origin.y = 5
        HeaderImageView.center.x = HeaderUIView.center.x
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        HeaderImageView.contentMode = UIViewContentMode.scaleAspectFit
        HeaderUIView.addSubview(HeaderImageView)
        // プロフィール編集ボタンの設定、画像の下に配置
        EditProfileButton.frame.size = CGSize(width: 250, height: 45)
        EditProfileButton.frame.origin.y = 220
        EditProfileButton.center.x = HeaderUIView.center.x
        EditProfileButton.backgroundColor = UIColor(hex: "17A589")
        EditProfileButton.layer.cornerRadius = 10
        EditProfileButton.addTarget(self,action: #selector(self.editProfileButtonTapped(sender:)),for: .touchUpInside)
        HeaderUIView.addSubview(EditProfileButton)
        
        //ログアウトボタンの設定、本番では消す
        LogOutButton.frame.size = CGSize(width: 200, height: 30)
        LogOutButton.frame.origin.y = 10
        LogOutButton.center.x = HeaderUIView.center.x
        LogOutButton.backgroundColor = UIColor.brown
        LogOutButton.addTarget(self,action: #selector(self.LogOutButtonTapped(sender:)),for: .touchUpInside)
        HeaderUIView.addSubview(LogOutButton)
        
        print(self.HeaderUIView.frame.height + self.EditProfileButton.frame.height + 20)
        
        // 上部に画像とボタンを設定
        form +++ Section(){ section in
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    return self.HeaderUIView
                }))
                header.height = { self.HeaderImageView.frame.height + self.EditProfileButton.frame.height + 20 }
                return header
            }()
        }
        
        // プロフィールを表示
        self.form +++ Section("プロフィール")
            <<< TextRow("UserName") {
                $0.title = "ユーザー名"
                $0.value = savedProfile.UserName
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("Gender") {
                $0.title = "性別"
                $0.value = savedProfile.Gender
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("Age") {
                $0.title = "年齢"
                $0.value = savedProfile.Age
                $0.baseCell.isUserInteractionEnabled = false
            }
            <<< TextRow("Level") {
                $0.title = "バスケットの経験"
                $0.value = savedProfile.Level
                $0.baseCell.isUserInteractionEnabled = false
        }
        self.form +++ Section("自由記述")
            <<< TextAreaRow("Comments") {
                $0.value = savedProfile.Comments == nil ? "": savedProfile.Comments
                $0.baseCell.isUserInteractionEnabled = false
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
        }
        // チュートリアルに遷移するセル
        self.form +++ Section("チュートリアル")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "チュートリアルを見る"
                }
                .onCellSelection { cell, row in
                    self.performSegue(withIdentifier: "toTutorial", sender: self)
        }
        // 問い合わせ先を表示するセル
        self.form +++ Section("問い合わせ")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "問い合わせをする"
                }
                .onCellSelection { cell, row in
                    // メールアプリを起動し、問い合わせる
                    // メールが送信可能な状態かチェック
                    if MFMailComposeViewController.canSendMail() {
                        let mail = MFMailComposeViewController()
                        mail.mailComposeDelegate = self
                        mail.setToRecipients(["xxx@xxx.xxx"]) // 宛先アドレス
                        mail.setSubject("問い合わせ") // 件名
                        mail.setMessageBody("お問い合わせ内容をご入力ください。", isHTML: false) // 本文
                        self.present(mail, animated: true, completion: nil)
                    } else {
                        print("送信できません")
                    }
        }
        // 利用規約ページに遷移するセル
        self.form +++ Section("利用規約")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "利用規約を読む"
                }
                .onCellSelection { cell, row in
                    self.performSegue(withIdentifier: "toTermsofUse", sender: self)
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
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func editProfileButtonTapped(sender : AnyObject) {
        // 現在のユーザー情報を取得
        self.CurrentUser = Auth.auth().currentUser
        // 匿名認証の場合、アラートを出す
        if self.CurrentUser!.isAnonymous {
            let alert: UIAlertController = UIAlertController(title: "プロフィールを作成するにはアカウントが必要です", message: "アカウントを作成しますか？", preferredStyle:  UIAlertControllerStyle.alert)
            // OKボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
                // 認証ページの準備
                var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
                let providers: [FUIAuthProvider] = [
                    FUIGoogleAuth(),
                    FUIFacebookAuth(),
                    FUITwitterAuth(),
                    FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
                    ]
                authUI.delegate = self
                authUI.providers = providers
                authUI.isSignInWithEmailHidden = true
                //　認証ページに遷移
                let authViewController = self.authPickerViewController(forAuthUI: authUI)
                self.present(authViewController, animated: true, completion: nil)
            })
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                //　アラートを閉じる
                alert.dismiss(animated: true, completion: nil)
            })
            // UIAlertControllerにActionを追加
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            // Alertを表示
            present(alert, animated: true, completion: nil)
        } else {
            // 匿名認証でない場合、プロフィール編集画面に遷移
            self.performSegue(withIdentifier: "toProfileDetail", sender: nil)
        }
        
    }
    
    @objc func LogOutButtonTapped(sender : AnyObject) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    //　認証画面から離れたときに呼ばれる（キャンセルボタン押下含む）
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        // 認証に成功した場合
        if error == nil {
            // 匿名認証のユーザー情報をFirebaseから削除
            self.CurrentUser.delete { error in
                if let error = error {
                    print(error)
                }
                // エラーが出た時の処理を書かないといけない
            }
        }
    }
    
    // カスタムした認証画面を返す
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let CustomAuthView = FUIAuthPickerViewController(authUI: authUI)
        CustomAuthView.view.backgroundColor = UIColor(hex: "D45000")
        return CustomAuthView
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("キャンセル")
        case .saved:
            print("下書き保存")
        case .sent:
            print("送信成功")
        default:
            print("送信失敗")
        }
        dismiss(animated: true, completion: nil)
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
