//
//  DetailViewController.swift
//  SportsMatching
//
//  Created by user on 2018/08/08.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import Foundation
import UIKit

class SearchResultDetailViewController: UIViewController{
    
    @IBOutlet weak var DetailImage: UIImageView!
    @IBOutlet weak var DetailLabel: UILabel!
    var selectedImg:UIImage!
    var selectedTxt:String!

    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DetailImage.frame.size = CGSize(width: 200, height: 200)
        DetailImage.image = selectedImg
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        DetailImage.contentMode = UIViewContentMode.scaleAspectFit
        DetailLabel.text = selectedTxt
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
