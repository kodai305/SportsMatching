//
//  TermsofUseViewController.swift
//  SportsMatching
//
//  Created by user on 2018/09/16.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit

class TermsOfUseViewController: BaseViewController {
    
    let termsOfUse_1 = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsOfUse_1.text = "ここに利用規約を書く予定"
        termsOfUse_1.frame.origin = CGPoint(x: 20, y: 100)
        termsOfUse_1.sizeToFit()
        self.view.addSubview(termsOfUse_1)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
