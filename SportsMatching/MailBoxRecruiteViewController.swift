//
//  MailBoxRecruiteViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/08.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DZNEmptyDataSet
import FirebaseCore
import FirebaseFunctions
import FirebaseFirestore

class MailBoxRecruiteViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var StubRecruiteHistory:[String] = []

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //デリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        //セルの高さを設定（100に設定）
        self.tableView.rowHeight = 100

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
        return StubRecruiteHistory.count
    }
    
    func tableView(_ table: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 設定したIDでUITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "RecruiteMailBoxCell",
                                             for: indexPath) as! MailBoxCell

        // 準備
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        // roomIDを求める
        var myUID = ""
        let defaults = UserDefaults.standard
        myUID = defaults.string(forKey: "UID")!
        let partnerID = StubRecruiteHistory[indexPath.row]
        let roomID = myUID+"-"+partnerID
        
        // 募集者の名前を取得
        var userName = "NoName"
        if let tmpName = defaults.string(forKey: "user_"+partnerID) {
            print("!!!!!!!!!")
            print(tmpName)
            userName = tmpName
        }
        
        // トーク履歴を取得
        var lastMessage:String = ""
        var lastMsgTime:String = "xx:xx:xx"
        if let data = defaults.data(forKey: roomID) {
            let savedMessage = try? JSONDecoder().decode([MessageInfo].self, from: data)
            lastMessage = savedMessage![(savedMessage?.count)!-1].message
            lastMsgTime = dateFormater.string(from: savedMessage![(savedMessage?.count)!-1].sentDate)
        }
        
        //チャット相手の情報をセルに表示
        cell.PartnerNameLabel.text = "相手:"+userName
        cell.LatestMessage.text = "最後のメッセージ:"+lastMessage
        cell.LatestExchangeTime.text = lastMsgTime
        cell.PartnerImageView.image = UIImage(named: "naito")
        
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
            // 募集履歴から遷移することを伝達
            nextViewController.fromWhichFlag = 1
        }
    }

    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "まだ募集がありません"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        tableView.tableFooterView = UIView(frame: .zero)
        return NSAttributedString(string: str, attributes: attrs)
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



