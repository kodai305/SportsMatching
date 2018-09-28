//
//  SearchResultViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/06.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD
import DZNEmptyDataSet

class SearchResultViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    // サムネイル画像格納用
    var postedImage = UIImage(named: "sample")
    // firestoreから読み込んだDocumentを格納する配列
    var LoadedDocumentArray:[QueryDocumentSnapshot] = []
    var LoadedImageArray:[UIImage] = []
    // 検索フォームから種目名と都道県名を受け取る変数
    var category:String!
    var prefecture:String!
    // 詳細画面に渡すdocument
    var sendDocument:QueryDocumentSnapshot!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.rowHeight = self.view.frame.height / 3
        self.tableView.backgroundColor = UIColor(hex: "FDEDEC", alpha: 2.0)
        
        SVProgressHUD.show(withStatus: "検索中")
        
        let db = Firestore.firestore()
        
        //postsコレクションから条件に一致するドキュメントを取得
        db.collection("posts")
            .whereField("category", isEqualTo: self.category)
            .whereField("prefecture", isEqualTo: self.prefecture)
            //.limit(to: 5)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        print(String(describing: type(of: document.data())))
                        self.LoadedDocumentArray.append(document)
                    }
                    print("loadcount :")
                    print(self.LoadedDocumentArray.count)
                    self.setTableview()
                    
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    func setTableview() {
        //デリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        //セルの高さを設定（画面全体の3分の1に設定）
        self.tableView.rowHeight = self.view.frame.height / 3
        self.tableView.reloadData()
        //0件の時はここでSVProgressを消す
        if self.LoadedDocumentArray.count == 0{
            SVProgressHUD.showSuccess(withStatus: "投稿がありません")
            SVProgressHUD.dismiss(withDelay: 2)
        }
        
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
        print("return")
        return  self.LoadedDocumentArray.count
    }
    
    
    func tableView(_ table: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 設定したIDでUITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "SerachResultCell",
                                             for: indexPath) as! SerachResultCell

        //画像をfirestoreから取得
        // XXX: ファイルが有るかをチェックとかが必要？
        let storage   = Storage.storage()
        let postUser  = LoadedDocumentArray[indexPath.row].data()["postUser"] as! String
        let imagePath = postUser + "/post/image.jpg"
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storage.reference().child(imagePath).getData(maxSize: 1 * 1024 * 1024 * 20) { data, error in //サイズ超過してるファイルがあるため*20
            if let error = error {
                print(error)
                self.postedImage = UIImage(named: "sample")
            } else {
                // Data for "images/island.jpg" is returned
                self.LoadedImageArray[indexPath.row] = UIImage(data: data!)!
                cell.ImageView.image = UIImage(data: data!)!
                print("download succeed!")
            }
            SVProgressHUD.showSuccess(withStatus: String(self.LoadedDocumentArray.count) + "件の投稿があります")
            SVProgressHUD.dismiss(withDelay: 2)
        }

        
        //        let ratio:CGFloat = ResizedImageView.frame.size.height / 100
        //        ResizedImageView.frame.size = CGSize(width: ResizedImageView.frame.size.width / ratio, height: ResizedImageView.frame.size.height / ratio)
        
        //Cellに画像と文章をセット
        let teamName:String = LoadedDocumentArray[indexPath.row].data()["teamName"] as! String
        cell.TeamNameLabel.text = teamName //XXX: null check
        cell.TeamNameLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        cell.TeamNameLabel.frame.origin.x = 20
        cell.TeamNameLabel.center.y = self.view.frame.height / 21 * 1
        cell.TeamNameLabel.sizeToFit()
        
        let category:String = LoadedDocumentArray[indexPath.row].data()["category"] as! String
        cell.CategoryLabel.text = "カテゴリー　: " + category //XXX: null check
        cell.CategoryLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        cell.CategoryLabel.frame.origin.x = 30
        cell.CategoryLabel.center.y = self.view.frame.height / 21 * 2
        cell.CategoryLabel.sizeToFit()

        let place:String = LoadedDocumentArray[indexPath.row].data()["place"] as! String
        cell.PlaceLabel.text = "活動場所　　: " + place
        cell.PlaceLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        cell.PlaceLabel.frame.origin.x = 30
        cell.PlaceLabel.center.y = self.view.frame.height / 21 * 3
        cell.PlaceLabel.sizeToFit()
        
        let gender:String = LoadedDocumentArray[indexPath.row].data()["applyGender"] as! String
        cell.GenderLabel.text = "募集性別　　: " + gender
        cell.GenderLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        cell.GenderLabel.frame.origin.x = 30
        cell.GenderLabel.center.y = self.view.frame.height / 21 * 4
        cell.GenderLabel.sizeToFit()
        
        let timezone = LoadedDocumentArray[indexPath.row].data()["timezone"] as! Array<String>
        var string:String!
        for i in 0 ..< timezone.count {
            string = i == 0 ? timezone[i] : timezone[i] + "," + string
        }
        cell.TimezoneLabel.text = "活動時間帯　: " + string
        cell.TimezoneLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        cell.TimezoneLabel.frame.origin.x = 30
        cell.TimezoneLabel.center.y = self.view.frame.height / 21 * 5
        cell.TimezoneLabel.sizeToFit()
        
        let updatedtime = LoadedDocumentArray[indexPath.row].data()["updateTime"] as! String
        cell.UpdatedTimeLabel.text = updatedtime
        cell.UpdatedTimeLabel.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        cell.UpdatedTimeLabel.sizeToFit()
        cell.UpdatedTimeLabel.frame.origin.x = self.view.frame.size.width / 2
        cell.UpdatedTimeLabel.center.y = self.view.frame.height / 21 * 6.3
        
        //FireStorageから画像がロード出来ていないのでSampleをセット
        self.LoadedImageArray.append(UIImage(named: "sample")!)
        cell.ImageView.image = UIImage(named: "sample")
        cell.ImageView.frame.size = CGSize(width: 130, height: 130)
        cell.ImageView.center = CGPoint(x: self.view.frame.width - 85, y: self.view.frame.height / 6.5)

        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除 //書かないと審査に通らない? cf.http://mjk0513.hateblo.jp/entry/2017/07/01/220542
        tableView.deselectRow(at: indexPath, animated: true)
        
        // [indexPath.row] から画像名を探し、UImage を設定　-> postsのdocumentを渡す, 画像は別でも良いかも
        self.postedImage = LoadedImageArray[indexPath.row]
        self.sendDocument = LoadedDocumentArray[indexPath.row]

        // Segueを呼び出す
        performSegue(withIdentifier: "toDetailViewController",sender: nil)
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toDetailViewController" {
            let nextView:SearchResultDetailViewController = segue.destination as! SearchResultDetailViewController
            nextView.postDoc = self.sendDocument
            nextView.selectedImg = self.postedImage
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "条件に該当する投稿がありません"
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
