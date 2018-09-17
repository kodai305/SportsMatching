//
//  AuthViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/09.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import FirebaseUI

class TopAuthenticationViewController: UIViewController,FUIAuthDelegate {
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
        FUIFacebookAuth(),
        //FUITwitterAuth(),
        FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ログイン済みかをチェック
        // didloadで行うとAppDelegateの実行前に実行され、エラーになるので注意
        self.checkLoggedIn()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkLoggedIn() {
        authUI.delegate = self
        self.authUI.providers = providers
        Auth.auth().addStateDidChangeListener{auth, user in
            if user != nil{
                //サインインしている
                self.present((self.storyboard?.instantiateViewController(withIdentifier:
                    "toMain"))!,animated: true,completion: nil)
            } else {
                //サインインしていない
                self.login()
            }
        }
    }
    
    func login() {
        // Google、Facebook、電話番号、メールの認証ボタンの画面に遷移
        let authViewController = authUI.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    //ログインに成功したときに呼ばれる
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        self.present((self.storyboard?.instantiateViewController(withIdentifier:
            "toMain"))!,animated: true,completion: nil)
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
