//
//  SearchResultViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/06.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SearchResultViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    let temp = ["naito", "okada","kenny","riria"]
    var SearchResults:[(prefecture: String, teamName: String)] = []
    
    var selectedImage:UIImage!
    var TeamName:String = ""
    var PrefectureName:String = ""
    
    //検索フォームから種目名と都道県名を受け取る変数
    var events:String!
    var prefecture:String!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let db = Firestore.firestore()
        //種目名でcollectionからデータを取得
        db.collection(events).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if document.data()["prefecture"] != nil {
                        //取得したデータをSearchResultsに追加する
                        let ResultData = (prefecture: document.data()["prefecture"].unsafelyUnwrapped, teamName: document.data()["teamName"].unsafelyUnwrapped)
                        self.SearchResults.append(ResultData as! (prefecture: String, teamName: String))
                    }
                }
            }
            //セルの高さ
            self.tableView.rowHeight = 100
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // セクション数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // セクションの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.SearchResults.count
    }
    
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 設定したIDでUITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "CustomCell",
                                             for: indexPath) as! CustomCell
        //Cellに画像と文章をセット
        //画像をセルの高さに合わせてリサイズ
        let ResizedImageView = UIImageView(image:UIImage(named: temp[indexPath.row]))
        let ratio:CGFloat = ResizedImageView.frame.size.height / 100
        ResizedImageView.frame.size = CGSize(width: ResizedImageView.frame.size.width / ratio, height: ResizedImageView.frame.size.height / ratio)
        cell.ImageView.addSubview(ResizedImageView)
        cell.TeamNameLabel.text = SearchResults[indexPath.row].teamName
        cell.PrefectureNameLabel.text = SearchResults[indexPath.row].prefecture
        cell.TeamNameLabel.frame.origin = CGPoint(x: 110, y: 30)
        cell.PrefectureNameLabel.frame.origin = CGPoint(x: 110, y: 60)
        cell.ImageView.frame.origin = CGPoint(x: 0, y: 0)
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        // [indexPath.row] から画像名を探し、UImage を設定
        selectedImage = UIImage(named: temp[indexPath.row])
        self.TeamName = SearchResults[indexPath.row].prefecture
        self.PrefectureName = SearchResults[indexPath.row].teamName
        if selectedImage != nil {
            // SubViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "toDetailViewController",sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toDetailViewController" {
            let nextView:SearchResultDetailViewController = segue.destination as! SearchResultDetailViewController
            nextView.selectedImg = selectedImage
            nextView.TeamName = self.TeamName
            nextView.PrefectureName = self.PrefectureName
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
