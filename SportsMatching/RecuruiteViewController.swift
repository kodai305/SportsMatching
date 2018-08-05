//
//  RecuruiteViewController.swift
//  
//
//  Created by 高木広大 on 2018/08/05.
//

import UIKit
import Eureka
import ImageRow

class RecuruiteViewController: FormViewController {

    // 選択されたイメージ格納用
    var selectedImg = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section(header: "必須項目", footer: "すべての項目を入力してくだいさい")
            <<< NameRow("teamName") {
                $0.title = "チーム名"
                $0.placeholder = "チーム名/サークル名"
            }
            <<< TextRow("prefecture"){
                $0.title = "都道府県"
                $0.placeholder = "プルダウンにしたい"
            }
            <<< TextRow("place"){
                $0.title = "活動場所"
                $0.placeholder = "体育館など"
            }
            <<< TextRow("time"){
                $0.title = "活動時間"
                $0.placeholder = "時間、頻度を入力"
        }
        
        form +++ Section(header: "任意項目", footer: "応募者が参考にするため、なるべく入力してください")
            <<< TextRow("recruiteAge") {
                $0.title = "募集年齢"
                $0.placeholder = "例：18歳から30歳まで"
            }
            <<< TextRow("memberInfo") {
                $0.title = "メンバー構成"
                $0.placeholder = "例：20歳男子中心"
            }
            <<< TextRow("memberAge"){
                $0.title = "平均年齢"
                $0.placeholder = "例：20台後半中心"
            }
            <<< ImageRow() {
                $0.title = "活動風景画像"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                $0.value = UIImage(named: "activeImage")
                $0.clearAction = .yes(style: .destructive)
                $0.onChange { [unowned self] row in
                            self.selectedImg = row.value!
                }
        }
        form +++ Section(header: "募集内容/連絡事項", footer: "不特定多数の方が見るため連絡先の掲載はお控えください")
            <<< TextAreaRow("freeWrite") {
                $0.placeholder = "自由記述"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
        }
        
        // Do any additional setup after loading the view.
    }

    @IBAction func postButton(_ sender: Any) {
        // XXX: 投稿ボタンを押した際の処理を実装する
        
        // XXX: 必須項目の入力チェック
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
