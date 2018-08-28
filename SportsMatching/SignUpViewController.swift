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
import FacebookLogin
import GoogleSignIn

class SignUpViewController: UIViewController,LoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var GoogleSingInButton: GIDSignInButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        usernameTextField.layer.borderWidth = 2
        emailTextField.layer.borderWidth = 2
        passTextField.layer.borderWidth = 2
        
        usernameTextField.placeholder = "user name"
        emailTextField.placeholder = "email"
        passTextField.placeholder = "pass"
        
        //Facebookのログインボタン
        let loginButton = LoginButton(readPermissions: [ .email ])
        loginButton.delegate = UIApplication.shared.delegate as? LoginButtonDelegate
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        //Googleのログインボタン
        //Google認証
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pushSignupButton(_ sender: Any) {
        if let username = usernameTextField.text,
            let email = emailTextField.text,
            let password = passTextField.text {
            if username.isEmpty {
                SVProgressHUD.showError(withStatus: "Oops!")
                usernameTextField.layer.borderColor = UIColor.red.cgColor
                return
            }
            if email.isEmpty {
                SVProgressHUD.showError(withStatus: "Oops!")
                emailTextField.layer.borderColor = UIColor.red.cgColor
                return
            }
            if password.isEmpty {
                SVProgressHUD.showError(withStatus: "Oops!")
                passTextField.layer.borderColor = UIColor.red.cgColor
                return
            }
            usernameTextField.layer.borderColor = UIColor.black.cgColor
            emailTextField.layer.borderColor = UIColor.black.cgColor
            passTextField.layer.borderColor = UIColor.black.cgColor
            
            SVProgressHUD.show()
            
            // ユーザー作成
            Auth.auth().createUser(withEmail: email, password: password) { user, error in
                if let error = error {
                    print(error)
                    SVProgressHUD.showError(withStatus: "Error!")
                    return
                }
                // ユーザーネームを設定
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = username
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print(error)
                            SVProgressHUD.showError(withStatus: "Error!")
                            return
                        }
                        SVProgressHUD.showSuccess(withStatus: "Success!")
                        
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            self.present((self.storyboard?.instantiateViewController(withIdentifier: "SignIn"))!,
                                         animated: true,
                                         completion: nil)
                        }
                    }
                } else {
                    print("Error - User not found")
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    //facebook認証関連
    //loginButtonDidCompleteLogin:result:を追加
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case let LoginResult.failed(error):
            print(error)
            break
        case let LoginResult.success(_, _, token):
            let credential = FacebookAuthProvider.credential(withAccessToken: token.authenticationToken)
            // Firebaseにcredentialを渡してlogin
            Auth.auth().signInAndRetrieveData(with: credential) { (fireUser, fireError) in
                if let error = fireError {
                    print(error)
                    print("cant connect firebase")
                    return
                }
                // ログインに成功した場合の挙動
                if let loginVC = self.presentedViewController{
                    print("success")
                    //facebookのログイン画面を閉じる
                    loginVC.dismiss(animated: true, completion: nil)
                    //  main画面へ遷移
                    let storyboard:UIStoryboard =  UIStoryboard(name: "Main",bundle:nil)
                    let mainview = storyboard.instantiateViewController(withIdentifier: "toMain")
                    self.present(mainview, animated: true, completion: nil)
                }
            }
        default:
            break
        }
        
    }
    //loginButtonDidLogOutを追加
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("loginButtonDidLogOut")
    }
    
    //Google認証関連
    @IBAction func GoogleSingInButtonClicked(sender: AnyObject) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("Google Sing In didSignInForUser")
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // Firebaseにcredentialを渡してlogin
        Auth.auth().signInAndRetrieveData(with: credential) { (fireUser, fireError) in
            if let error = fireError {
                print(error)
                print("cant connect firebase")
                return
            }
            print("success")
            //  main画面へ遷移
            self.present((self.storyboard?.instantiateViewController(withIdentifier:
                "toMain"))!,animated: true,completion: nil)
        }
    }
    
    //ログインがキャンセル・失敗した場合
    func sign(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: Error!) {
        print("Google Sing In didDisconnectWithUser")
        // Perform any operations when the user disconnects from app here.
        // ...
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
