//
//  BaseFormViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/19.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import FirebaseAuth
import Eureka

class BaseFormViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // When user status is changed, this pocess is executed
        Auth.auth().addStateDidChangeListener { (auth, user) in
            // [START_EXCLUDE]
            if user != nil {
                //サインインしている
                print("user:")
                print(user?.uid)
                self.saveUID(uid: (user?.uid)!)
            } else {
                //サインインしていない
                print("ログインをしてください")
            }
            // [END_EXCLUDE]
        }
    }
    
    func saveUID (uid: String) {
        if uid.isEmpty {
            print("認証してください")
            // TODO: 警告, 認証画面への遷移ロジックを追加する
            
        } else {
            // UIDをuser defaultに保存
            // TODO: 保存してあるUIDと違ったら警告を出したほうがいいかもしれない
            let defaults = UserDefaults.standard
            defaults.set(uid ,forKey: "UID")
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
