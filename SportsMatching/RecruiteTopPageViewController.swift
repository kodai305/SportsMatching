//
//  RecruiteTopPageViewController.swift
//  SportsMatching
//
//  Created by user on 2018/09/23.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI

class RecruiteTopPageViewController: UIViewController,FUIAuthDelegate {
    
    @IBOutlet weak var NewPostButton: UIButton!
    @IBOutlet weak var EditPostButton: UIButton!
    
    var CurrentUser:User!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NewPostButton.addTarget(self,action: #selector(self.NewPostButtonTapped(sender:)),for: .touchUpInside)
        EditPostButton.addTarget(self,action: #selector(self.EditPostButtonTapped(sender:)),for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    @objc func NewPostButtonTapped(sender : AnyObject) {
        
        let defaults = UserDefaults.standard
        // 現在のユーザー情報を取得
        self.CurrentUser = Auth.auth().currentUser
        // 匿名認証の場合、アラートを出す
        if self.CurrentUser!.isAnonymous {
            let alert: UIAlertController = UIAlertController(title: "メンバーの募集を行うには認証が必要です", message: "認証を行いますか？", preferredStyle:  UIAlertControllerStyle.alert)
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
            //　投稿がない場合、遷移
            if defaults.data(forKey: "recruite") == nil {
                self.performSegue(withIdentifier: "toRecruiteView", sender: nil)
            } else {
                //  投稿がある場合、確認のアラートを出す
                //  UIAlertControllerクラスのインスタンスを生成
                let alert: UIAlertController = UIAlertController(title: "投稿済みの募集が消去されます", message: "新規で募集しますか？", preferredStyle:  UIAlertControllerStyle.alert)
                
                // OKボタン
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    // 新規投稿画面に遷移
                    self.performSegue(withIdentifier: "toRecruiteView", sender: nil)
                    
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
        }
    }
    
    @objc func EditPostButtonTapped(sender : AnyObject) {
        
        let defaults = UserDefaults.standard
        //　投稿がない場合、 確認のアラートを出す
        if defaults.data(forKey: "recruite") == nil {
            //  UIAlertControllerクラスのインスタンスを生成
            let alert: UIAlertController = UIAlertController(title: "募集の履歴がありません", message: "新規投稿から募集してください", preferredStyle:  UIAlertControllerStyle.alert)
            
            // OKボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
                //　アラートを閉じる
                alert.dismiss(animated: true, completion: nil)
                
            })
            
            // UIAlertControllerにActionを追加
            alert.addAction(defaultAction)
            // Alertを表示
            present(alert, animated: true, completion: nil)
        } else {
            //  投稿がある場合、編集ページに遷移
            self.performSegue(withIdentifier: "toEditRecruiteView", sender: nil)
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
