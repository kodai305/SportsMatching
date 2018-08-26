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

class SearchResultViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource {
    // サムネイル画像格納用
    var postedImage:UIImage!
    // firestoreから読み込んだDocumentを格納する配列
    var LoadedDocumentArray:[QueryDocumentSnapshot] = []
    // 検索フォームから種目名と都道県名を受け取る変数
    var category:String!
    var prefecture:String!
    // 詳細画面に渡すdocument
    var sendDocument:QueryDocumentSnapshot!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.show(withStatus: "検索中")
        //デリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //セルの高さを設定（画面全体の5分の1に設定）
        self.tableView.rowHeight = self.view.frame.height / 5
        
        let db = Firestore.firestore()
        
        //postsコレクションから条件に一致するドキュメントを取得
        db.collection("posts")
            .whereField("category", isEqualTo: category)
            .whereField("prefecture", isEqualTo: prefecture)
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
                    print("count :")
                    print(self.LoadedDocumentArray.count)
                    //ここでreloadすると、検索結果一覧画面を開いている場合reloadが繰り返される
                    self.tableView.reloadData()
                    SVProgressHUD.showSuccess(withStatus: String(self.LoadedDocumentArray.count) + "件の投稿があります")
                    SVProgressHUD.dismiss(withDelay: 2)
                }
            }

        print("count :")
        print(self.LoadedDocumentArray.count)
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
        let imagePath = postUser + "/post/image1.jpg"
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storage.reference().child(imagePath).getData(maxSize: 1 * 1024 * 1024 * 20) { data, error in //サイズ超過してるファイルがあるため*20
            if let error = error {
                print(error)
                self.postedImage = UIImage(named: "sample")
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.postedImage = image
                print("download succeed!")
                self.tableView.reloadData()
            }
        }

        //Cellに画像と文章をセット
        //画像をセルの高さに合わせてリサイズ
        let ResizedImageView = UIImageView(image: self.postedImage)
//        let ratio:CGFloat = ResizedImageView.frame.size.height / 100
//        ResizedImageView.frame.size = CGSize(width: ResizedImageView.frame.size.width / ratio, height: ResizedImageView.frame.size.height / ratio)
        ResizedImageView.frame.size = CGSize(width: 100, height: 100)
        cell.ImageView.addSubview(ResizedImageView)

        let teamName:String = LoadedDocumentArray[indexPath.row].data()["teamName"] as! String
        cell.TeamNameLabel.text = "チーム名: " + teamName //XXX: null check
        cell.TeamNameLabel.frame.origin = CGPoint(x: 110, y: 30)

        let prefecture:String = LoadedDocumentArray[indexPath.row].data()["prefecture"] as! String
        cell.PrefectureNameLabel.text = "都道府県: " + prefecture
        cell.PrefectureNameLabel.frame.origin = CGPoint(x: 110, y: 60)

        cell.ImageView.frame.origin = CGPoint(x: 10, y: 10)
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除 //書かないと審査に通らない? cf.http://mjk0513.hateblo.jp/entry/2017/07/01/220542
        tableView.deselectRow(at: indexPath, animated: true)
        
        // [indexPath.row] から画像名を探し、UImage を設定　-> postsのdocumentを渡す, 画像は別でも良いかも
        self.postedImage = UIImage(named: "sample")
        self.sendDocument = LoadedDocumentArray[indexPath.row]

        // Segueを呼び出す
        performSegue(withIdentifier: "toDetailViewController",sender: nil)
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toDetailViewController" {
            let nextView:SearchResultDetailViewController = segue.destination as! SearchResultDetailViewController
            nextView.postDoc = self.sendDocument
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
