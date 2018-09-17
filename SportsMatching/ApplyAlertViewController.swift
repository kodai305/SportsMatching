//
//  ApplyAlertViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/09/17.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit

class ApplyAlertViewController: UIViewController {
    
    @IBAction func SendButton(_ sender: Any) {
        
    }
    
    @IBAction func CancelButton(_ sender: Any) {
//        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func unwind(_ segue:UIStoryboardSegue){}
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var AlertTitleLabel: UILabel!
    @IBOutlet weak var AlertSubscriptionLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
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

/**
 *  Show ---------------------
 */
extension ApplyAlertViewController {
    class func show(presentintViewController vc: UIViewController) {
        guard let alert = UIStoryboard(name: "ApplyAlertViewController", bundle: nil).instantiateInitialViewController() as? ApplyAlertViewController else { return }
        vc.present(alert, animated: true, completion: nil)
    }
}
