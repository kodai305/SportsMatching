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
        Auth.auth().addStateDidChangeListener{auth, user in
            if user != nil{
                //サインインしている
                self.present((self.storyboard?.instantiateViewController(withIdentifier:
                    "toMain"))!,animated: true,completion: nil)
            } else {
                //サインインしていない
                // 認証ボタン、匿名認証ボタンの設定
                // Google、Facebook、Twitter、電話番号の認証ボタンの画面に遷移
                self.authUI.delegate = self
                self.authUI.isSignInWithEmailHidden = true
                self.authUI.providers = self.providers
                let authViewController = EditedAuthViewController(authUI: self.authUI)
                self.present(authViewController, animated: false, completion: nil)
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //認証画面から離れたときに呼ばれる（キャンセルボタン押下含む）
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        // 認証に成功した場合
        if error == nil {
            self.present((self.storyboard?.instantiateViewController(withIdentifier:
                "toMain"))!,animated: true,completion: nil)
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

