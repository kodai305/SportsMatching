//
//  SearchViewController.swift
//  SportsMatching
//
//  Created by user on 2018/08/09.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import FirebaseFirestore

class SearchViewController: FormViewController {

    // 選択されたイメージ格納用
    var selectedImg = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section(header: "必須項目", footer: "すべての項目を入力してください")
            <<< NameRow("events") {
                $0.title = "種目"
                $0.placeholder = "プルダウン？"
                $0.value = "" //初期値
            }
            <<< TextRow("prefecture"){
                $0.title = "都道府県"
                $0.placeholder = "プルダウンにしたい"
                $0.value = "" 
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toResultViewController" {
            let nextView:SearchResultViewController = segue.destination as! SearchResultViewController
            // タグ設定済みの全てのRowの値を取得
            let values = form.values()
            // Rowの値を取得する
            nextView.events = values["events"] as! String
            nextView.prefecture = values["prefecture"] as! String
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
