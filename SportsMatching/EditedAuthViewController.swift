//
//  EditedAuthViewController.swift
//  SportsMatching
//
//  Created by user on 2018/10/22.
//  Copyright © 2018 iosearn. All rights reserved.
//

import UIKit
import FirebaseUI


// FUIAuthPickerViewControllerは子View[0]に利用規約
// 子View[1]に各プロバイダのボタンをまとめたUIViewを持っている
// 子View[1]の位置がconstraintsでもframe指定でも動かせないので
// 各プロバイダのボタンViewを取り出し、上位Viewの子Viewにさ設定
class EditedAuthViewController: FUIAuthPickerViewController{
    
    let GuestUserButton = UIButton()
    let iconImageView = UIImageView(image: UIImage(named: "Icon"))
    // ゲストアカウント（匿名認証）時に呼ばれた場合に1
    var guestAccountFlag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scrennSize: CGSize = UIScreen.main.bounds.size
        // 各プロバイダのボタンをまとめたUIViewから各プロバイダのボタンのViewを取得
        let googleAuthButton = self.view.subviews[1].subviews[0]
        let facebookAuthButton = self.view.subviews[1].subviews[1]
        let twitterAuthButton = self.view.subviews[1].subviews[2]
        let phoneAuthButton = self.view.subviews[1].subviews[3]
        
        // ゲストアカウント（匿名認証）ボタンの準備
        self.GuestUserButton.frame.size = CGSize(width: googleAuthButton.frame.width, height: googleAuthButton.frame.height)
        self.GuestUserButton.setTitle("ゲストアカウント", for: .normal)
        self.GuestUserButton.setTitleColor(UIColor.white, for: .normal)
        self.GuestUserButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.GuestUserButton.layer.borderColor = UIColor.white.cgColor
        self.GuestUserButton.layer.borderWidth = 1
        self.GuestUserButton.addTarget(self,action: #selector(self.guestUserButtonTapped(sender:)),for: .touchUpInside)
        
        // 画面中央のアイコン画像
        self.iconImageView.contentMode = UIViewContentMode.scaleAspectFit
        self.iconImageView.frame.size = CGSize(width: 140, height: 140)
        self.iconImageView.center = CGPoint(x: scrennSize.width / 2, y: scrennSize.height / 2)
        
        // レイアウトを設定
        googleAuthButton.frame.origin.y = self.iconImageView.frame.origin.y + self.iconImageView.frame.height
        facebookAuthButton.frame.origin.y = googleAuthButton.frame.origin.y + 50
        twitterAuthButton.frame.origin.y = facebookAuthButton.frame.origin.y + 50
        phoneAuthButton.frame.origin.y = twitterAuthButton.frame.origin.y + 50
        self.GuestUserButton.frame.origin.y = phoneAuthButton.frame.origin.y + 50
        googleAuthButton.center.x = self.iconImageView.center.x
        facebookAuthButton.center.x = self.iconImageView.center.x
        twitterAuthButton.center.x = self.iconImageView.center.x
        phoneAuthButton.center.x = self.iconImageView.center.x
        self.GuestUserButton.center.x = self.iconImageView.center.x
        
        // 最上位Viewの子Viewに設定
        self.view.addSubview(self.iconImageView)
        self.view.addSubview(googleAuthButton)
        self.view.addSubview(facebookAuthButton)
        self.view.addSubview(twitterAuthButton)
        self.view.addSubview(phoneAuthButton)
        if self.guestAccountFlag != 1{
            self.view.addSubview(self.GuestUserButton)
        }
        
        // 元々あった各プロバイダのボタンをまとめたUIViewを削除
        self.view.subviews[1].removeFromSuperview()
        
        // 背景色をオレンジに変更
        self.view.backgroundColor = UIColor(hex: "D45000")

        // Do any additional setup after loading the view.
    }
    
    // 匿名認証を行う（ゲストユーザー）
    @objc func guestUserButtonTapped(sender : AnyObject) {
        
        //  投稿がある場合、確認のアラートを出す
        //  UIAlertControllerクラスのインスタンスを生成
        let alert: UIAlertController = UIAlertController(title: "ゲストアカウントはいくつかの機能が制限されます", message: "ゲストアカウントで始めますか？", preferredStyle:  UIAlertControllerStyle.alert)
        
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            Auth.auth().signInAnonymously() { (user, error) in
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                self.present((storyboard.instantiateViewController(withIdentifier:
                    "toMain")),animated: true,completion: nil)
            }
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
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
