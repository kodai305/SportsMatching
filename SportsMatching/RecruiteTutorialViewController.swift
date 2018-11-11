//
//  RecruiteTutorialViewController.swift
//  SportsMatching
//
//  Created by user on 2018/10/15.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit

class RecruiteTutorialViewController: BaseViewController,UIScrollViewDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    let numberOfPages = 4
    //UIPageControlのインスタンス作成
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
        let firstImage = UIImageView(image: UIImage(named: "PostTutorialImage1.png"))
        firstImage.frame.size.height = firstUIView.frame.height * 0.8
        firstImage.center = CGPoint(x: firstUIView.frame.width * 0.5, y: firstUIView.frame.height * 0.45)
        firstImage.contentMode = UIViewContentMode.scaleAspectFit
        
        let firstLable = UILabel()
        firstLable.text = "メンバーを募集するには下のタブで \n「メンバー募集」をタップし \n 「新規投稿」をタップして下さい"
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
        let secondImage = UIImageView(image: UIImage(named: "PostTutorialImage2.png"))
        secondImage.frame.size.height = scrollView.frame.height * 0.8
        secondImage.center = CGPoint(x: scrollView.frame.width * 0.5, y: scrollView.frame.height * 0.45)
        secondImage.contentMode = UIViewContentMode.scaleAspectFit
        
        let secondLable = UILabel()
        secondLable.text = "メンバー募集の投稿を行うには \n 必須条件の入力が必要です"
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
        let thirdImage = UIImageView(image: UIImage(named: "PostTutorialImage3.png"))
        thirdImage.frame.size.height = scrollView.frame.height * 0.8
        thirdImage.center = CGPoint(x: scrollView.frame.width * 0.5, y: scrollView.frame.height * 0.45)
        thirdImage.contentMode = UIViewContentMode.scaleAspectFit
        
        let thirdLable = UILabel()
        thirdLable.text = "必須条件を入力したら \n 右上の「投稿」をタップして下さい"
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
        let fourthImage = UIImageView(image: UIImage(named: "PostTutorialImage4.png"))
        fourthImage.frame.size.height = scrollView.frame.height * 0.8
        fourthImage.center = CGPoint(x: scrollView.frame.width * 0.5, y: scrollView.frame.height * 0.45)
        fourthImage.contentMode = UIViewContentMode.scaleAspectFit
        
        let fourthLable = UILabel()
        fourthLable.text = "投稿した募集に応募があった場合 \n 「メッセージ履歴」タブに通知があります"
        fourthLable.numberOfLines = 3
        fourthLable.font = UIFont.systemFont(ofSize: 16.0)
        fourthLable.sizeToFit()
        fourthLable.frame.origin.y = fourthUIView.frame.height - fourthLable.frame.height
        fourthLable.center.x = fourthImage.center.x
        fourthUIView.addSubview(fourthImage)
        fourthUIView.addSubview(fourthLable)
        scrollView.addSubview(fourthUIView)
        
        
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
