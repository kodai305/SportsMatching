//
//  MailViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/10.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import MessageKit
import FirebaseFunctions
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD
import GoogleMobileAds

class MailViewController: MessagesViewController, GADBannerViewDelegate {
    lazy var functions = Functions.functions()
    // メッセージ一覧画面から受け取る値
    var partnerUID = ""
    var roomID = ""
    
    // 募集履歴と応募履歴のどちらから来たかを管理するFlag
    var fromRecruiteFlag = 0
    var fromSearchFlag = 0
    
    var senderType = "Applicant" // or Recruiter
    
    // 画像のダウンロードが完了しているかのFlag
    var downloadSucceedFlag = 0
    
    // FireStoreから取得したDocumentを保存（応募者のプロフィールを保存or応募した投稿内容）
    var GottenDoc:DocumentSnapshot!
    
    //　FirebaseStorageから取得した画像を保存
    var GottenUIImage:UIImage!
    
    // 使うかどうかは後回し
    //let refreshControl = UIRefreshControl()
    
    // メッセージ内容に関するプロパティ
    var messageList: [MockMessage] = []
    
    //
    @IBOutlet weak var ShowDetailButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // メッセージのload
        self.loadMessages()
        
        // 背景に画像を設定
        let BGUIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        BGUIImageView.image = UIImage(named: "chatBG")
        //self.view.addSubview(BGUIImageView)
        messagesCollectionView.backgroundView = BGUIImageView
        
        // MocMessageを使う場合は全部実装する必要がある
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.blue
        
        // 詳細ボタンの設定
        // 募集履歴から遷移してきた場合
        if fromRecruiteFlag == 1 && fromSearchFlag == 0 {
            ShowDetailButton.title = "応募者のプロフィール"
            self.senderType = "Recruiter" // 自分自身は募集者
        } else if fromRecruiteFlag == 0 && fromSearchFlag == 1 {
            // 応募履歴から遷移してきた場合
            ShowDetailButton.title = "応募した投稿の内容"
            self.senderType = "Applicant"
        }
        ShowDetailButton.action = #selector(self.ShowDetailButtonTapped(sender:))
        
        // メッセージ入力時に一番下までスクロール
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false

        displayAdvertisement()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 一番下までスクロールする
        self.messagesCollectionView.scrollToBottom()
        print("scroll to bottom called")
        
        //　募集履歴から遷移してきた場合
        if fromRecruiteFlag == 1 && fromSearchFlag == 0 {
            // 相手の最新のプロフィールを取得
            // 相手のプロフィールが変更されるたびに呼ばれる
            let db = Firestore.firestore()
            db.collection("users").document(partnerUID)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    print("Current data: \(String(describing: document.data()))")
                    self.GottenDoc = document
                    // FirebaseStorageから画像を取得
                    self.getImageFromFirebaseStorage(path: "profile")
            }
        } else if fromRecruiteFlag == 0 && fromSearchFlag == 1 {
            // 応募履歴から遷移してきた場合、最新の投稿内容を取得
            // 投稿内容が変更されるたびに呼ばれる
            let db = Firestore.firestore()
            db.collection("posts").document(partnerUID)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    print("Current data: \(String(describing: document.data()))")
                    self.GottenDoc = document
                    // FirebaseStorageから画像を取得
                    self.getImageFromFirebaseStorage(path: "post")
            }
        }
    }
    
    func getImageFromFirebaseStorage(path: String){
        //画像をfirestoreから取得
        let storage   = Storage.storage()
        let imagePath = self.partnerUID + "/" + path + "/image.jpg"
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storage.reference().child(imagePath).getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
                self.GottenUIImage = UIImage(named: "sample")!
            } else {
                // ダウンロード成功
                self.GottenUIImage = UIImage(data: data!)
                self.downloadSucceedFlag = 1
                print("download succeed!")
            }
        }
    }
    
    // メッセージの読込/保存
    func saveMessages(text: String, mocMessage: MockMessage) {
        // 保存するmessageInfo配列
        var messageArray:[MessageInfo] = []
        
        // 今回追加するメッセージ
        var stubMessageInfo = MessageInfo()
        stubMessageInfo.message  = text
        stubMessageInfo.senderID = mocMessage.sender.id
        stubMessageInfo.sentDate = mocMessage.sentDate
        stubMessageInfo.kind     = "text"
        
        let defaults = UserDefaults.standard
        // 空だった場合
        guard let data = defaults.data(forKey: self.roomID) else {
            var stubMessageInfo = MessageInfo()
            stubMessageInfo.message  = text
            stubMessageInfo.senderID = mocMessage.sender.id
            stubMessageInfo.sentDate = mocMessage.sentDate
            stubMessageInfo.kind     = "text"
            messageArray.append(stubMessageInfo)
            let data = try? JSONEncoder().encode(messageArray)
            defaults.set(data ,forKey: self.roomID)
            return
        }
        // 保存してあるデータがあった場合、既存のものに追加する
        let savedMessage = try? JSONDecoder().decode([MessageInfo].self, from: data)
        messageArray = savedMessage!
        messageArray.append(stubMessageInfo)
        
        // 保存
        let data2 = try? JSONEncoder().encode(messageArray)
        defaults.set(data2 ,forKey: self.roomID)
    }
    
    func loadMessages() {
        let defaults  = UserDefaults.standard
        // 保存してあるデータが空の場合(基本的にはない??)
        guard let data = defaults.data(forKey: self.roomID) else {
            return
        }
        // 保存してあるデータが有る場合
        let savedMessageInfoArray = try? JSONDecoder().decode([MessageInfo].self, from: data)
        
        for messageInfo in savedMessageInfoArray! {
            let attributedText = NSAttributedString(string: messageInfo.message, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
            let _sender = Sender(id: messageInfo.senderID, displayName: "")
            let message = MockMessage(attributedText: attributedText, sender: _sender, messageId: UUID().uuidString, date: messageInfo.sentDate)
            self.messageList.append(message)
            print(messageInfo)
        }
    }
    
    func saveDisplayedMessageNumber(messageNumber: Int) {
        let _key = "DisplayedNumber_"+self.roomID
        let defaults = UserDefaults.standard
        defaults.set(messageNumber, forKey: _key)
        print("saveDisplayMessageNumber:")
        print(messageNumber)
    }
    
    // 応募者のプロフィールor応募した投稿内容を表示する画面に遷移
    @objc func ShowDetailButtonTapped(sender : AnyObject) {
        print("messages_count:")
        print(messageList.count)
        print(self.partnerUID)
        // 画像がダウンロード出来ていれば遷移
        if self.downloadSucceedFlag == 1{
            performSegue(withIdentifier: "toPostDetailViewController",sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetailViewController" {
            let destinationView = segue.destination as! PostDetailViewController
            //　必要な値を渡す
            destinationView.GottenDoc = self.GottenDoc
            destinationView.fromRecruiteFlag = self.fromRecruiteFlag
            destinationView.fromSearchFlag = self.fromSearchFlag
            destinationView.GottenUIImage = self.GottenUIImage
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

        let navigationController: UINavigationController = UINavigationController()
        let navigationHeight = navigationController.navigationBar.frame.size.height
        bannerView.frame.origin = CGPoint(x:0, y: bannerView.frame.height)
        bannerView.frame.size = CGSize(width:self.view.frame.width, height:navigationHeight + bannerView.frame.height + 20)

        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        self.view.addSubview(bannerView)
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

extension MailViewController: MessagesDataSource {
    // 自分の情報を設定
    func currentSender() -> Sender {
        let myUID: String = UserDefaults.standard.string(forKey: "UID")!
        return Sender(id: myUID, displayName: "")
    }
    
    // 表示するメッセージの数
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        saveDisplayedMessageNumber(messageNumber: self.messageList.count)
        return messageList.count
    }
    
    // メッセージの実態。返り値はMessageType
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    // XXX: アバターの設定
    // func configureAvatarView()
    
    // 自動で電話番号やURLを検出
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in     messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }
    
}

// MARK: - MessagesLayoutDelegate
extension MailViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 10
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension MailViewController: MessageInputBarDelegate {
    // メッセージ送信ボタンをタップした時の挙動
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // セマフォを0で初期化
        let semaphore = DispatchSemaphore(value: 0)
        
        // Each NSTextAttachment that contains an image will count as one empty character in the text: String
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
            } else if let text = component as? String {
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
                
                let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                
                if sendNewMessageNotification(text: text) == true {
                    print("true")
                    // messageの追加
                    self.messageList.append(message)
                    messagesCollectionView.insertSections([self.messageList.count - 1])
                    saveMessages(text: text, mocMessage: message)
                } else {
                    print("false")
                }
            }
            semaphore.signal()
        }
        // セマフォをデクリメント（-1）、ただしセマフォが0の場合はsignal()の実行を待つ
        semaphore.wait()
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
    
    func sendNewMessageNotification(text: String) -> Bool {
        print("function is called")
        SVProgressHUD.show(withStatus: "送信中")
        var ret = false
        self.functions.httpsCallable("sendNewMessageNotification").call(["partnerUID": self.partnerUID, "message": text, "roomID": self.roomID, "senderType": self.senderType]) { (result, error) in
            var returnMsg = ""
            if result?.data is NSDictionary {
                let resultData = result?.data as! NSDictionary
                returnMsg  = resultData["returnMsg"] as! String
            }
            // result -> nil = ネットワークに繋がってない
            if result == nil {
                ret = false
                SVProgressHUD.showError(withStatus: "ネットワークに繋がっているか確認してください")
            } else if returnMsg == "error" { // returnMsg = error -> cloud functionでerrorを返してきた場合
                ret = false
                SVProgressHUD.showError(withStatus: "送信失敗\nお問い合わせください")
                print("returnMsg:")
                print(returnMsg)
            } else if let error = error as NSError? {
                SVProgressHUD.showError(withStatus: "送信失敗\nお問い合わせください")
                ret = false
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                }
            } else {
                SVProgressHUD.showSuccess(withStatus: "送信成功")
                ret = true
            }
        }
        return ret
    }
}

// MARK: - MessagesDisplayDelegate
extension MailViewController: MessagesDisplayDelegate {
    // メッセージの色を変更（デフォルトは自分：黒、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        //        return isFromCurrentSender(message: message) ? .white : .darkText
        return isFromCurrentSender(message: message) ? .black : .black
    }
    
    // メッセージの背景色を変更している（デフォルトは自分：緑、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    // メッセージの枠にしっぽを付ける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let initName = message.sender.displayName
        // そこからイニシャルを生成するとよい
        let avatar = Avatar(initials: initName)
        avatarView.set(avatar: avatar)
    }
    
}

// MARK: - MessageCellDelegate
extension MailViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
}

