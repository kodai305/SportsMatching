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
import SVProgressHUD

class MailViewController: MessagesViewController {
    lazy var functions = Functions.functions()
    // メッセージ一覧画面から受け取る値
    var partnerUID = ""
    var roomID = ""
    
    // メッセージの構造体(保存用)
    struct MessageInfo: Codable {
        var message: String = ""
        var senderID: String = ""
        var sentDate: Date = Date()
        var kind: String = ""
    }
    
    // 使うかどうかは後回し
    //let refreshControl = UIRefreshControl()
    
    // メッセージ内容に関するプロパティ
    var messageList: [MockMessage] = []
    
    // デバッグ用
    @IBAction func testButtonPushed(_ sender: Any) {
        print("messages_count:")
        print(messageList.count)
        print(self.partnerUID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // MocMessageを使う場合は全部実装する必要がある
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        messageInputBar.sendButton.tintColor = UIColor.blue
        // メッセージのload
        self.loadMessages()
        
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
            let attributedText = NSAttributedString(string: messageInfo.message, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
            let _sender = Sender(id: messageInfo.senderID, displayName: "")
            let message = MockMessage(attributedText: attributedText, sender: _sender, messageId: UUID().uuidString, date: messageInfo.sentDate)
            self.messageList.append(message)
            print(messageInfo)
        }
        
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
        return Sender(id: myUID, displayName: "自分")
    }
    
    // 表示するメッセージの数
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
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
        
        // Each NSTextAttachment that contains an image will count as one empty character in the text: String
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                
                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
                
            } else if let text = component as? String {
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
                
                let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                
                self.messageList.append(message)
                messagesCollectionView.insertSections([self.messageList.count - 1])
                
                saveMessages(text: text, mocMessage: message)
                
                testRecvMessage()
                
                sendNewMessageNotification(text: text)
            }
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
    
    // テスト用 メッセージを返す
    func testRecvMessage() {
        let attributedText = NSAttributedString(string: "返信", attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        let message = MockMessage(attributedText: attributedText, sender: Sender(id: "11111", displayName: "相手"), messageId: UUID().uuidString, date: Date())
        
        self.messageList.append(message)
        messagesCollectionView.insertSections([self.messageList.count - 1])
    }
    
    func sendNewMessageNotification(text: String) {
        self.functions.httpsCallable("sendNewMessageNotification").call(["partnerUID": self.partnerUID, "message": text]) { (result, error) in
            // XXX: user nameも送りたい
            
            print(result?.data as Any)
            print("function is called")
            if let error = error as NSError? {
                SVProgressHUD.showError(withStatus: "失敗")
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                }
            } else {
                SVProgressHUD.showSuccess(withStatus: "成功")
            }
        }
    }
    
}

// MARK: - MessagesDisplayDelegate
extension MailViewController: MessagesDisplayDelegate {
    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        //        return isFromCurrentSender(message: message) ? .white : .darkText
        return isFromCurrentSender(message: message) ? .white : .black
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

