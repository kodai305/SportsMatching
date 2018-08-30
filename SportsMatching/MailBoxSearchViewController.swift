//
//  MailBoxSearchViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/08.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DZNEmptyDataSet

class MailBoxSearchViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider ,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    @IBOutlet weak var tableView: UITableView!

    var StubApplyHistory:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //デリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        //セルの高さを設定（画面全体の5分の1に設定）
        self.tableView.rowHeight = self.view.frame.height / 5
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 今までの応募履歴を取得
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "ApplyHistory") != nil {
            StubApplyHistory = defaults.value(forKey: "ApplyHistory") as! [String]
        }
        self.tableView.reloadData()
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
        return StubApplyHistory.count
    }
    
    func tableView(_ table: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 設定したIDでUITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "SearchMailBoxCell",
                                             for: indexPath) as! MailBoxCell
        //チャット相手のIDをセルに表示
        cell.PartnerNameLabel.text = StubApplyHistory[indexPath.row]

        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除 
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Segueを呼び出す
        let postID = StubApplyHistory[indexPath.row]
        performSegue(withIdentifier: "toMailMatsueViewController",sender: postID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMailMatsueViewController" {
            // UIDを取得
            var myUID = ""
            let defaults = UserDefaults.standard
            myUID = defaults.string(forKey: "UID")!
            let partnerUID = sender as! String
            
            // こうしないとNavigationControllerに値渡しできない
            let nav = segue.destination as! UINavigationController
            let nextViewController = nav.topViewController as! MailViewController
            nextViewController.partnerUID = partnerUID
            nextViewController.roomID = partnerUID+"-"+myUID //roomID = "投稿者UID" + "-" + "応募者UID"
            
        }
    }
    
    //tableViewのセクションの行数が0の時小島さんの画像を出す
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        tableView.tableFooterView = UIView(frame: .zero)
        return UIImage(named: "riria")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "まだ募集がありません"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
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
