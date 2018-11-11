//
//  SearchTutorialViewController.swift
//  SportsMatching
//
//  Created by user on 2018/10/15.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit

class SearchTutorialViewController: BaseViewController,UIScrollViewDelegate {
    
    // チュートリアルを表示するScrollView
    @IBOutlet weak var scrollView: UIScrollView!
    let numberOfPages = 6
    // 現在のページ位置を表示するドット用のUIPageControl
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // AutoRayoutで決めるScorllViewのサイズはviewDidLayoutSubviewsの前で決まるため
    // ここで中身の定義を行う
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 枚数に合わせてscrollViewのcontentSizeの幅を変える
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(numberOfPages), height: scrollView.frame.height)
        // スワイプした時にページめくりされる
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        // 1枚目の画像と説明文
        let firstUIView = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        let firstImage = UIImageView(image: UIImage(named: "SearchTutorialImage1.png"))
        firstImage.frame.size.height = firstUIView.frame.height * 0.8
        firstImage.center = CGPoint(x: firstUIView.frame.width * 0.5, y: firstUIView.frame.height * 0.45)
        firstImage.contentMode = UIViewContentMode.scaleAspectFit
        
        let firstLable = UILabel()
        firstLable.text = "チームを検索するには下のタブで \n「チーム検索」をタップして \n 検索条件を入力して下さい"
        firstLable.numberOfLines = 0
        firstLable.font = UIFont.systemFont(ofSize: 16.0)
        firstLable.sizeToFit()
        firstLable.frame.origin.y = firstUIView.frame.height - firstLable.frame.height
        firstLable.center.x = firstImage.center.x
        firstUIView.addSubview(firstImage)
        firstUIView.addSubview(firstLable)
        scrollView.addSubview(firstUIView)
        
        // 2枚目の画像
        let secondUIView = UIView(frame: CGRect(x: scrollView.frame.width * 1, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        let secondImage = UIImageView(image: UIImage(named: "SearchTutorialImage2.png"))
        secondImage.frame.size.height = scrollView.frame.height * 0.8
        secondImage.center = CGPoint(x: scrollView.frame.width * 0.5, y: scrollView.frame.height * 0.45)
        secondImage.contentMode = UIViewContentMode.scaleAspectFit
        
        let secondLable = UILabel()
        secondLable.text = "検索条件を入力したら \n 右上の「検索」ボタンをタップして下さい"
        secondLable.numberOfLines = 2
        secondLable.font = UIFont.systemFont(ofSize: 16.0)
        secondLable.sizeToFit()
        secondLable.frame.origin.y = secondUIView.frame.height - secondLable.frame.height
        secondLable.center.x = secondImage.center.x
        secondUIView.addSubview(secondImage)
        secondUIView.addSubview(secondLable)
        scrollView.addSubview(secondUIView)
        
        // 3枚目の画像
        let thirdUIView = UIView(frame: CGRect(x: scrollView.frame.width * 2, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        let thirdImage = UIImageView(image: UIImage(named: "SearchTutorialImage3.png"))
        thirdImage.frame.size.height = scrollView.frame.height * 0.8
        thirdImage.center = CGPoint(x: scrollView.frame.width * 0.5, y: scrollView.frame.height * 0.45)
        thirdImage.contentMode = UIViewContentMode.scaleAspectFit
        
        let thirdLable = UILabel()
        thirdLable.text = "条件に合うチームが表示されます \n 気になるチームをタップすると \n 詳細を見ることが出来ます"
        thirdLable.numberOfLines = 3
        thirdLable.font = UIFont.systemFont(ofSize: 16.0)
        thirdLable.sizeToFit()
        thirdLable.frame.origin.y = thirdUIView.frame.height - thirdLable.frame.height
        thirdLable.center.x = thirdImage.center.x
        thirdUIView.addSubview(thirdImage)
        thirdUIView.addSubview(thirdLable)
        scrollView.addSubview(thirdUIView)
        
        // 4枚目の画像
        let fourthUIView = UIView(frame: CGRect(x: scrollView.frame.width * 3, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        let fourthImage = UIImageView(image: UIImage(named: "SearchTutorialImage4.png"))
        fourthImage.frame.size.height = scrollView.frame.height * 0.8
        fourthImage.center = CGPoint(x: scrollView.frame.width * 0.5, y: scrollView.frame.height * 0.45)
        fourthImage.contentMode = UIViewContentMode.scaleAspectFit
        
        let fourthLable = UILabel()
        fourthLable.text = "チームに応募したい場合は \n 右上の「応募」ボタンをタップして下さい"
        fourthLable.numberOfLines = 3
        fourthLable.font = UIFont.systemFont(ofSize: 16.0)
        fourthLable.sizeToFit()
        fourthLable.frame.origin.y = fourthUIView.frame.height - fourthLable.frame.height
        fourthLable.center.x = fourthImage.center.x
        fourthUIView.addSubview(fourthImage)
        fourthUIView.addSubview(fourthLable)
        scrollView.addSubview(fourthUIView)
        
        // 5枚目の画像
        let fifthUIView = UIView(frame: CGRect(x: scrollView.frame.width * 4, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        let fifthImage = UIImageView(image: UIImage(named: "SearchTutorialImage5.png"))
        fifthImage.frame.size.height = scrollView.frame.height * 0.8
        fifthImage.center = CGPoint(x: scrollView.frame.width * 0.5, y: scrollView.frame.height * 0.45)
        fifthImage.contentMode = UIViewContentMode.scaleAspectFit
        
        let fifthLable = UILabel()
        fifthLable.text = "チーム管理者へのメッセージを入力し \n 「送信」ボタンをタップして下さい"
        fifthLable.numberOfLines = 3
        fifthLable.font = UIFont.systemFont(ofSize: 16.0)
        fifthLable.sizeToFit()
        fifthLable.frame.origin.y = fifthUIView.frame.height - fifthLable.frame.height
        fifthLable.center.x = fifthImage.center.x
        fifthUIView.addSubview(fifthImage)
        fifthUIView.addSubview(fifthLable)
        scrollView.addSubview(fifthUIView)
        
        // 6枚目の画像
        let sixthUIView = UIView(frame: CGRect(x: scrollView.frame.width * 5, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        let sixthImage = UIImageView(image: UIImage(named: "SearchTutorialImage6.png"))
        sixthImage.frame.size.height = scrollView.frame.height * 0.8
        sixthImage.center = CGPoint(x: scrollView.frame.width * 0.5, y: scrollView.frame.height * 0.45)
        sixthImage.contentMode = UIViewContentMode.scaleAspectFit
        
        let sixthLable = UILabel()
        sixthLable.text = "メッセージ履歴タブで \n チーム管理者とやり取りし \n バスケチームに参加しましょう！"
        sixthLable.numberOfLines = 3
        sixthLable.font = UIFont.systemFont(ofSize: 16.0)
        sixthLable.sizeToFit()
        sixthLable.frame.origin.y = sixthUIView.frame.height - sixthLable.frame.height
        sixthLable.center.x = sixthImage.center.x
        sixthUIView.addSubview(sixthImage)
        sixthUIView.addSubview(sixthLable)
        scrollView.addSubview(sixthUIView)
        
        //スクロールビューのページ位置を表すドットを追加
        //ページ数の設定
        pageControl.numberOfPages = numberOfPages
        //現在ページの設定
        pageControl.currentPage = 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //スクロール距離 = 1ページ(画面幅)
        if fmod(scrollView.contentOffset.x, scrollView.frame.width) == 0 {
            //ページの切り替え
            self.pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
