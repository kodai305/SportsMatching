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
    @IBOutlet weak var TeamNameLabel: UILabel!
    @IBOutlet weak var PrefectureLabel: UILabel!
    //検索結果一覧からデータを受け取る変数
    var selectedImg:UIImage!
    var TeamName:String!
    var PrefectureName:String!

    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //検索結果一覧から受け取ったデータを表示
        DetailImage.frame.size = CGSize(width: 200, height: 200)
        DetailImage.image = selectedImg
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        DetailImage.contentMode = UIViewContentMode.scaleAspectFit
        TeamNameLabel.text = TeamName
        PrefectureLabel.text = PrefectureName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
