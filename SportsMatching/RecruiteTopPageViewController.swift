//
//  RecruiteTopPageViewController.swift
//  SportsMatching
//
//  Created by user on 2018/09/23.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit

class RecruiteTopPageViewController: UIViewController {
    
    @IBOutlet weak var NewPostButton: UIButton!
    @IBOutlet weak var EditPostButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NewPostButton.addTarget(self,action: #selector(self.NewPostButtonTapped(sender:)),for: .touchUpInside)
        EditPostButton.addTarget(self,action: #selector(self.EditPostButtonTapped(sender:)),for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    @objc func NewPostButtonTapped(sender : AnyObject) {
        
        let defaults = UserDefaults.standard
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
