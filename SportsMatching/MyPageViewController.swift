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

class MyPageViewController: BaseFormViewController {
    
    let HeaderImageView = UIImageView()
    let HeaderUIView = UIView()
    
    @IBOutlet weak var EditProfileButton: UIButton!

    //ログアウトボタン(開発用、本番では消す)
    @IBAction func LogOutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Userdefalutsからプロフィールを取得
        var savedProfile = Profile()
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "profile"){
            savedProfile = try! JSONDecoder().decode(Profile.self, from: data)
            HeaderImageView.image = UIImage(data: savedProfile.Image)
            self.EditProfileButton.setTitle("プロフィールを編集", for: .normal)
        } else{ //プロフィール作成されてない場合
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
        
        EditProfileButton.frame.size = CGSize(width: 200, height: 30)
        EditProfileButton.frame.origin.y = 210
        EditProfileButton.center.x = HeaderUIView.center.x
        EditProfileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        EditProfileButton.backgroundColor = UIColor.red
        EditProfileButton.setTitleColor(UIColor.black, for: .normal)
        EditProfileButton.addTarget(self,action: #selector(self.buttonTapped(sender:)),for: .touchUpInside)
        HeaderUIView.addSubview(EditProfileButton)
        
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
        self.form +++ Section(header: "利用規約", footer: "")
            <<< TextAreaRow("利用規約") {
                $0.value = "ここに利用規約をかく？"
                $0.baseCell.isUserInteractionEnabled = false
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func buttonTapped(sender : AnyObject) {
        self.performSegue(withIdentifier: "toProfileDetail", sender: nil)
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
