//
//  MailBoxRecruiteViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/08.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MailBoxRecruiteViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {
    
    var StubRecruiteHistory:[String] = []

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //デリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //セルの高さを設定（画面全体の5分の1に設定）
        self.tableView.rowHeight = self.view.frame.height / 5

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 今までの募集履歴を取得
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "RecruiteHistory") != nil {
            StubRecruiteHistory = defaults.value(forKey: "RecruiteHistory") as! [String]
        }
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "募集履歴"
    }
    
    // セクション数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // セクションの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ table: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 設定したIDでUITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "RecruiteMailBoxCell",
                                             for: indexPath) as! MailBoxCell
        cell.PartnerNameLabel.text = "データなし"
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除 //書かないと審査に通らない? cf.http://mjk0513.hateblo.jp/entry/2017/07/01/220542
        tableView.deselectRow(at: indexPath, animated: true)

        // Segueを呼び出す
        let postID = StubRecruiteHistory[indexPath.row]
        performSegue(withIdentifier: "toMailTakagiViewController",sender: postID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMailTakagiViewController" {
            // UIDを取得
            var myUID = ""
            let defaults = UserDefaults.standard
            myUID = defaults.string(forKey: "UID")!
            let partnerUID = sender as! String
            
            // こうしないとNavigationControllerに値渡しできない
            let nav = segue.destination as! UINavigationController
            let nextViewController = nav.topViewController as! MailViewController
            nextViewController.partnerUID = partnerUID
            nextViewController.roomID = myUID+"-"+partnerUID //roomID = "投稿者UID" + "-" + "応募者UID"
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



