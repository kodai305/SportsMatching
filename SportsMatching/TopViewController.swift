//
//  TopViewController.swift
//  SportsMatching
//
//  Created by user on 2018/09/26.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import FirebaseUI

class TopViewController: UIViewController,FUIAuthDelegate {
    
    
    @IBOutlet weak var AuthenticationButton: UIButton!
    @IBOutlet weak var GuestUserButton: UIButton!
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
        FUIFacebookAuth(),
        FUITwitterAuth(),
        FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // サインインしているかチェック
        authUI.delegate = self
        self.authUI.providers = providers
        Auth.auth().addStateDidChangeListener{auth, user in
            if user != nil{
                //サインインしている
                self.present((self.storyboard?.instantiateViewController(withIdentifier:
                    "toMain"))!,animated: true,completion: nil)
            } else {
                //サインインしていない
                // 認証ボタン、匿名認証ボタンの設定

                self.AuthenticationButton.layer.cornerRadius = 10
                self.AuthenticationButton.addTarget(self,action: #selector(self.authenticationButtonTapped(sender:)),for: .touchUpInside)
                
                self.GuestUserButton.layer.borderColor = UIColor.white.cgColor
                self.GuestUserButton.layer.borderWidth = 2
                self.GuestUserButton.layer.cornerRadius = 10
                self.GuestUserButton.addTarget(self,action: #selector(self.guestUserButtonTapped(sender:)),for: .touchUpInside)
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func authenticationButtonTapped(sender : AnyObject) {
        // Google、Facebook、電話番号、メールの認証ボタンの画面に遷移
        let authViewController = authUI.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    //認証画面から離れたときに呼ばれる（キャンセルボタン押下含む）
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        // 認証に成功した場合
        if error == nil {
            self.present((self.storyboard?.instantiateViewController(withIdentifier:
                "toMain"))!,animated: true,completion: nil)
        }
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
                self.present((self.storyboard?.instantiateViewController(withIdentifier:
                    "toMain"))!,animated: true,completion: nil)
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
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

