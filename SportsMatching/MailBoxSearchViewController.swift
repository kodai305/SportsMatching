//
//  MailBoxSearchViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/08.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MailBoxSearchViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider  {

    @IBOutlet weak var tableView: UITableView!
    
    //応募ボタンから遷移してきた時に応募先のユーザーIDを記録
    var PartnerID:String!
    let defaults = UserDefaults.standard
    //ユーザーID、時間、メッセージの順で格納したArrayで管理
    var MailHistory = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //デリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //セルの高さを設定（画面全体の5分の1に設定）
        self.tableView.rowHeight = self.view.frame.height / 5
        
        //時刻を取得(年月日、時分)
        let f = DateFormatter()
        f.timeStyle = .long
        f.dateStyle = .short
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        
        //今までのメール履歴を取得
        if defaults.value(forKey: "History") != nil{
            MailHistory = defaults.value(forKey: "History") as! [[String]]
            //応募ボタンからの遷移とそれ以外で分岐
            if PartnerID != nil{
                MailHistory.insert([PartnerID,f.string(from: now),"応募します"], at: 1)
                defaults.set(MailHistory, forKey: "History")
                self.tableView.reloadData()
            }else{
                self.tableView.reloadData()
            }
        }else{ //メール履歴がない場合
            if PartnerID != nil{
                MailHistory.append([PartnerID,f.string(from: now),"応募します"])
                defaults.set(MailHistory, forKey: "History")
                self.tableView.reloadData()
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "応募履歴"
    }
    
    // セクション数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // セクションの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MailHistory.count
    }
    
    func tableView(_ table: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 設定したIDでUITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "SearchMailBoxCell",
                                             for: indexPath) as! SearchMailBoxCell
        //今までのやりとりをセルに記録
        cell.PartnerNameLabel.text = MailHistory[indexPath.row][0]
        cell.LastMessageLabel.text = MailHistory[indexPath.row][1]
        cell.DateLabel.text = MailHistory[indexPath.row][2]
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除 //書かないと審査に通らない? cf.http://mjk0513.hateblo.jp/entry/2017/07/01/220542
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Segueを呼び出す
        performSegue(withIdentifier: "toMailMatsueViewController",sender: nil)
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
