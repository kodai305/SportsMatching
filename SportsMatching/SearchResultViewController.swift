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
    
    var selectedImage:UIImage!
    var selectedText:String!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //セルの高さ
        self.tableView.rowHeight = 100
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let db = Firestore.firestore()
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
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
        return temp.count
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
        cell.Label.text = temp[indexPath.row]
        cell.Label.frame.origin = CGPoint(x: 110, y: 0)
        cell.ImageView.frame.origin = CGPoint(x: 0, y: 0)
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        // [indexPath.row] から画像名を探し、UImage を設定
        selectedImage = UIImage(named: temp[indexPath.row])
        selectedText = temp[indexPath.row]
        if selectedImage != nil {
            // SubViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "toDetailViewController",sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toDetailViewController" {
            let nextView:ResultDetailViewController = segue.destination as! ResultDetailViewController
            nextView.selectedImg = selectedImage
            nextView.selectedTxt = selectedText
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
