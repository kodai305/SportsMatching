//
//  ViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/04.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import FirebaseAuth

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
            } else {
                //サインインしていない
                print("ログインをしてください")
            }
            // [END_EXCLUDE]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

