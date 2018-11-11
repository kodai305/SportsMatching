//
//  TutorialTopViewController.swift
//  SportsMatching
//
//  Created by user on 2018/11/11.
//  Copyright © 2018 iosearn. All rights reserved.
//

import UIKit

class TutorialTopViewController: UIViewController {
    
    
    @IBOutlet weak var recruiteTutorialButton: UIButton!
    @IBOutlet weak var searchTutorialButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recruiteTutorialButton.layer.cornerRadius = 10
        self.recruiteTutorialButton.addTarget(self,action: #selector(self.RecruiteTutorialButtonTapped(sender:)),for: .touchUpInside)
        
        self.searchTutorialButton.layer.cornerRadius = 10
        self.searchTutorialButton.addTarget(self,action: #selector(self.SearchTutorialButtonTapped(sender:)),for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func RecruiteTutorialButtonTapped(sender : AnyObject) {
        self.performSegue(withIdentifier: "toRecruiteTutorialView", sender: nil)
    }
    
    @objc func SearchTutorialButtonTapped(sender : AnyObject) {
        self.performSegue(withIdentifier: "toSearchTutorialView", sender: nil)
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
