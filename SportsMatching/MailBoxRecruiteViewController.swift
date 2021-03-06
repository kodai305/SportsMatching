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
    let cellHeight:CGFloat = 100
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // テーブルのサイズを画面サイズに合わせる
        self.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        //デリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        //セルの高さを設定（100に設定）
        self.tableView.rowHeight = self.cellHeight
        
        // 広告は非表示にしておく
        self.hideAdvertisement()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("recuite view will appear is called")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 今までの募集履歴を取得
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "RecruiteHistory") != nil {
            self.StubRecruiteHistory = defaults.value(forKey: "RecruiteHistory") as! [String]
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
        //roomID = "投稿者UID" + "-" + "応募者UID"
        let roomID = myUID+"-"+partnerID
        
        // 募集者の名前を取得
        var userName = "NoName"
        if let tmpName = defaults.string(forKey: "user_"+partnerID) {
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
        cell.PartnerNameLabel.text = userName
        cell.PartnerNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        cell.PartnerNameLabel.sizeToFit()
        cell.PartnerNameLabel.frame.origin.x = 120
        cell.PartnerNameLabel.center.y = self.cellHeight / 2
        
        cell.LatestMessage.text = lastMessage
        cell.LatestMessage.font = UIFont.systemFont(ofSize: 15)
        cell.LatestMessage.textColor = UIColor.gray
        cell.LatestMessage.sizeToFit()
        cell.LatestMessage.frame.size.width = cell.frame.width - 180
        cell.LatestMessage.frame.origin = CGPoint(x: 120, y: self.cellHeight * 3 / 4)
        
        cell.LatestExchangeTime.text = lastMsgTime
        cell.LatestExchangeTime.font = UIFont.systemFont(ofSize: 12)
        cell.LatestExchangeTime.textColor = UIColor.gray
        cell.LatestExchangeTime.sizeToFit()
        cell.LatestExchangeTime.frame.origin = CGPoint(x: self.view.frame.width - (cell.LatestExchangeTime.frame.width + 10), y: 10)
        
        cell.PartnerImageView.image = UIImage(named: "defaulticon")
        cell.PartnerImageView.frame = CGRect(x: 20, y: 20, width: 60, height: 60)
        
        // 未読数をLINE風に表示
        let unreadCount = Budge().getUnreadCount(_roomID: roomID)
        // 未読数が0の場合は非表示
        if unreadCount == 0 {
            cell.UnReadCountBadge.isHidden = true
        } else {
            // 未読数が1以上の場合
            cell.UnReadCountBadge.setTitle(String(unreadCount), for: .normal)
            cell.UnReadCountBadge.setTitleColor(UIColor.white, for: .normal)
            cell.UnReadCountBadge.frame.size = CGSize(width: 30, height: 30)
            cell.UnReadCountBadge.layer.cornerRadius = 15
            cell.UnReadCountBadge.backgroundColor = UIColor(hex: "D45000")
            cell.UnReadCountBadge.frame.origin.x = cell.frame.width - 40
            cell.UnReadCountBadge.center.y = cell.center.y + 10
        }
        
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
            nextViewController.fromRecruiteFlag = 1
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



