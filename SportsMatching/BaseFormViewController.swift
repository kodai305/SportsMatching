//
//  BaseFormViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/19.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import Eureka
import GoogleMobileAds
import SVProgressHUD

class BaseFormViewController: FormViewController, GADBannerViewDelegate {
    
    
    // FireStoreと通信中かを判断するためのFlag
    var isConnecting:Bool = false
    // 広告の上までスクロール出来るようにViewを広げる様の空のUIView
    let FooterUIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 背景色を設定
        self.tableView.backgroundColor = UIColor(hex: "EBEDEF")
        // Tabbar非選択時のアイコンの色を設定
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor(hex: "515A5A")

        //displayAdvertisement()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // When user status is changed, this pocess is executed
        Auth.auth().addStateDidChangeListener { (auth, user) in
            // [START_EXCLUDE]
            if user != nil {
                //サインインしている
                print("user:")
                print(user?.uid)
                self.saveUID(uid: (user?.uid)!)
            } else {
                //サインインしていない
                print("ログインをしてください")
                print(user?.uid as Any)
            }
            // [END_EXCLUDE]
        }
    }
    
    func saveUID (uid: String) {
        if uid.isEmpty {
            print("認証してください")
            // TODO: 警告, 認証画面への遷移ロジックを追加する
            
        } else {
            // UIDをuser defaultに保存
            // TODO: 保存してあるUIDと違ったら警告を出したほうがいいかもしれない
            let defaults = UserDefaults.standard
            defaults.set(uid ,forKey: "UID")
        }
    }
    
    // 投稿の詳細をUserdefaultsに保存する
    func savePostDetailtoUserdefautls(postedTime: String, updateTime: String, myUID: String, values: [String : Any?], selectedImgae: UIImage){
        let defaults = UserDefaults.standard
        var postDetail = PostDetail()
        postDetail.PostedTime = postedTime
        postDetail.UpdateTime = updateTime
        postDetail.PostUser = myUID
        postDetail.TeamName = values["TeamName"] as? String
        postDetail.Category = values["Category"] as? String
        postDetail.Prefecture = values["Prefecture"] as? String
        postDetail.Place = values["Place"] as? String
        postDetail.ApplyGender = values["ApplyGender"] as? String
        postDetail.Day = Array(values["Day"] as! Set<String>)
        postDetail.Image = UIImageJPEGRepresentation(selectedImgae, 0.1)!
        postDetail.Position = values["Position"].unsafelyUnwrapped == nil ? Array() : Array(values["Position"] as! Set<String>)
        postDetail.ApplyLevel = values["ApplyLevel"].unsafelyUnwrapped == nil ? Array() : Array(values["ApplyLevel"] as! Set<String>)
        postDetail.GenderRatio = values["GenderRatio"].unsafelyUnwrapped == nil ? "" : values["GenderRatio"] as! String
        postDetail.TeamLevel = values["TeamLevel"].unsafelyUnwrapped == nil ? "" : values["TeamLevel"] as! String
        postDetail.NumMembers = values["NumMembers"].unsafelyUnwrapped == nil ? 0 : values["NumMembers"] as! Int
        postDetail.Timezone = values["Timezone"].unsafelyUnwrapped == nil ? Array() : Array(values["Timezone"] as! Set<String>)
        postDetail.MainAge = values["MainAge"].unsafelyUnwrapped == nil ? Array() : Array(values["MainAge"] as! Set<String>)
        postDetail.Comments = values["Comments"].unsafelyUnwrapped == nil ? "" : values["Comments"] as! String
        let data = try? JSONEncoder().encode(postDetail)
        defaults.set(data ,forKey: "recruite")
    }

    
    // ImageCellで選択された画像をFirebaseStorageに保存
    func saveImagetoFirebaseStorage(directory: String, myUID: String, selectedImgae: UIImage, completion: (() -> ())?) {
        //Firebase Storageの準備
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // UIImageJPEGRepresentationでUIImageをNSDataに変換して格納
        var ImageShrinkRatio:CGFloat = 0.5
        if var data = UIImageJPEGRepresentation(selectedImgae, ImageShrinkRatio){
            //画像のファイルサイズが1024*1024bytes以下になるまで縮小係数を調整
            while data.count > 1024 * 1024{
                ImageShrinkRatio = ImageShrinkRatio - 0.1
                data = UIImageJPEGRepresentation(selectedImgae, ImageShrinkRatio)!
            }
            //とりあえずUIDのディレクトリを作成し、その下に画像を保存
            let reference = storageRef.child(myUID + "/" + directory + "/image.jpg")
            reference.putData(data, metadata: nil, completion: { metaData, error in
                if metaData != nil {
                    self.isConnecting = false
                    SVProgressHUD.showSuccess(withStatus: "成功")
                    completion?()
                    return
                } else {
                    print("in")
                    SVProgressHUD.showError(withStatus: "失敗")
                    self.isConnecting = false
                    return
                }
            })
        }
    }
    
    //　複数選択可能な項目で表示されるViewにおいて
    // 右上の「Done」ボタンをタップした時の処理
    @objc func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // Firestoreアクセス時に10秒レスポンスがなければ、ネットワークの確認のアラートを出す
    func prepareNetworkAlert() {
        // SVProgressHUDのNotificationを使って通信中のアラートがけ消えるタイミングで処理
        let center = NotificationCenter.default
        var token: NSObjectProtocol!
        token = center.addObserver(forName: .SVProgressHUDDidDisappear,
                                   object: nil,
                                   queue: nil) { notification in
                                    // 通信中のアラートが消えたことで呼ばれる場合
                                    if self.isConnecting {
                                        self.isConnecting = false
                                        SVProgressHUD.showInfo(withStatus: "ネットワークを確認して下さい")
                                        SVProgressHUD.dismiss(withDelay: 2)
                                    }
                                    center.removeObserver(token)
                                }
        }
    
    //let admob_id = "XXX" // 本番用
    let admob_id = "ca-app-pub-3940256099942544/2934735716" // 練習用

    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    // 広告の表示
    func displayAdvertisement() {
        print("display Advertisement is called")
        var bannerView = GADBannerView()
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = admob_id
        
        let tabBarController: UITabBarController = UITabBarController()
        let tabBarHeight = tabBarController.tabBar.frame.size.height
        bannerView.frame.origin = CGPoint(x:0, y:self.view.frame.size.height - tabBarHeight - bannerView.frame.height)
        bannerView.frame.size = CGSize(width:self.view.frame.width, height:bannerView.frame.height)
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        self.view.addSubview(bannerView)
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
