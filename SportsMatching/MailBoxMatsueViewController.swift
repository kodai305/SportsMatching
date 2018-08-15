//
//  MailBoxMatsueViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/10.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseFirestore

class MailBoxMatsueViewController: JSQMessagesViewController  {
    var messages: [JSQMessage] = []
    
    let db = Firestore.firestore()
    //チャット相手のID
    let partnerId = "test8"
    //subcollection内のdocument名用の数字
    var documentNumber:Int = 0
    //SnapShot内の処理が画面遷移時に起動しない様に管理
    var SnapFlag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //firestoreのおまじない（入れないとコンソールで警告）
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings

        
        senderDisplayName = "A"
        //自分のID
        senderId = "test7"
        
        //チャット相手との今までの履歴を取得
        //ここではdocument名をtest7_test8で固定
        db.collection("rooms-matsue").document("test7_test8")
            .collection("messages").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    //チャット起動時のメッセージ数(相手＋自分)を取得
                    self.documentNumber = querySnapshot!.documents.map { $0["body"]! }.count
                }
        }
        
        //チャット相手が送信したメッセージを自動で取得
        db.collection("rooms-matsue").document("test7_test8")
            .collection("messages").whereField("user", isEqualTo: partnerId)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                print("in")
                if self.SnapFlag != 0{
                    //相手が送ったメッセージを全て取得
                    let PartnerMessages = documents.map { $0["body"]! }
                    print(PartnerMessages)
                    //最新のメッセージを表示
                    let message = JSQMessage(senderId: self.partnerId, displayName: "B", text: PartnerMessages[PartnerMessages.count - 1] as! String)
                    self.messages.append(message!)
                    self.finishReceivingMessage(animated: true)
                    self.documentNumber = self.documentNumber + 1
                }else{
                    self.SnapFlag = 1
                }
        }
    }
    
    //アイテムごとに参照するメッセージデータを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    
    //アイテムごとのMessageBubble(背景)を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        if messages[indexPath.row].senderId == senderId {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(
                with: UIColor(red: 112/255, green: 192/255, blue:  75/255, alpha: 1))
        } else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(
                with: UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1))
        }
    }
    
    
    // cell for item
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        if messages[indexPath.row].senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.darkGray
        }
        return cell
    }
    
    
    // section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        //senderId == 自分　だった場合表示しない
        let senderId = messages[indexPath.row].senderId
        
        if senderId == "Dummy" {
            return nil
        }
        return JSQMessagesAvatarImage.avatar(with: UIImage(named: "okada"))
    }
    
    
    //時刻表示のための高さ調整
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        if indexPath.item == 0 {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            if message.date.timeIntervalSince(previousMessage.date) / 60 > 1 {
                return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
            }
        }
        return nil
    }
    
    
    // 送信時刻を出すために高さを調整する
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            let message = messages[indexPath.item]
            if message.date .timeIntervalSince(previousMessage.date) / 60 > 1 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        return 0.0
    }
    
    //Sendボタンが押された時に呼ばれる
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        //firestoreにメッセージを格納
        db.collection("rooms-matsue").document("test7_test8")
            .collection("messages").document("message" + String(documentNumber)).setData([
                "body":text,
                "date":"hoge",
                "name":"hoge",
                "user": senderId
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        documentNumber = documentNumber + 1
        
        //キーボードを閉じる
        self.view.endEditing(true)
        //メッセージを追加
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        self.messages.append(message!)
        //送信を反映
        self.finishReceivingMessage(animated: true)
        //textFieldをクリアする
        self.inputToolbar.contentView.textView.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
