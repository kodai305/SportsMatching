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

class MyPageViewController: BaseFormViewController,FUIAuthDelegate {
    
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
        HeaderImageView.frame.origin.y = 0
        HeaderImageView.center.x = HeaderUIView.center.x
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        HeaderImageView.contentMode = UIViewContentMode.scaleAspectFit
        HeaderUIView.addSubview(HeaderImageView)
        // プロフィール編集ボタンの設定、画像の下に配置
        EditProfileButton.frame.size = CGSize(width: 200, height: 30)
        EditProfileButton.frame.origin.y = 210
        EditProfileButton.center.x = HeaderUIView.center.x
        EditProfileButton.backgroundColor = UIColor.red
        EditProfileButton.setTitleColor(UIColor.black, for: .normal)
        EditProfileButton.addTarget(self,action: #selector(self.editProfileButtonTapped(sender:)),for: .touchUpInside)
        HeaderUIView.addSubview(EditProfileButton)
        
        //ログアウトボタンの設定、本番では消す
        LogOutButton.frame.size = CGSize(width: 200, height: 30)
        LogOutButton.frame.origin.y = 10
        LogOutButton.center.x = HeaderUIView.center.x
        LogOutButton.backgroundColor = UIColor.brown
        LogOutButton.addTarget(self,action: #selector(self.LogOutButtonTapped(sender:)),for: .touchUpInside)
        HeaderUIView.addSubview(LogOutButton)
        
        // 上部に画像とボタンを設定
        form +++ Section(){ section in
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    return self.HeaderUIView
                }))
                header.height = { 240 }
                return header
            }()
        }
        
        // プロフィールを表示
        self.form +++ Section(header: "ユーザー情報", footer: "")
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
                $0.title = "年代"
                $0.value = savedProfile.Age
                $0.baseCell.isUserInteractionEnabled = false
                }
            <<< TextRow("Level") {
                $0.title = "バスケットの経験"
                $0.value = savedProfile.Level
                $0.baseCell.isUserInteractionEnabled = false
        }
        // 利用規約ページに遷移するセル
        self.form +++ Section(header: "利用規約", footer: "")
            <<< LabelRow () {
                $0.title = "利用規約"
                $0.value = "利用規約を読む"
                }
                .onCellSelection { cell, row in
                    self.performSegue(withIdentifier: "toTermsofUse", sender: self)
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
            let alert: UIAlertController = UIAlertController(title: "プロフィールを作成するには認証が必要です", message: "認証を行いますか？", preferredStyle:  UIAlertControllerStyle.alert)
            // OKボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
                // 認証ページの準備
                var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
                let providers: [FUIAuthProvider] = [
                    FUIGoogleAuth(),
                    FUIFacebookAuth(),
                    //FUITwitterAuth(),
                    FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
                    ]
                authUI.delegate = self
                authUI.providers = providers
                //　認証ページに遷移
                let authViewController = authUI.authViewController()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
