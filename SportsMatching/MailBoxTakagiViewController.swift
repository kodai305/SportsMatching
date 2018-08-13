//
//  MailBoxTakagiViewController.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/08/10.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit
import JSQMessagesViewController



class MailBoxTakagiViewController: JSQMessagesViewController {

    // デバッグ用
    @IBAction func testButtonPushed(_ sender: Any) {
        print("messages_count:")
        print(messages.count)
    }
    
    // メッセージ内容に関するプロパティ
    var messages: [JSQMessage] = []
    
    // 背景画像に関するプロパティ
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    // アバター画像に関するプロパティ
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // メッセージのload
        //self.loadMessages()
        
        // クリーンアップツールバーの設定
        inputToolbar!.contentView!.leftBarButtonItem = nil
        // 新しいメッセージを受信するたびに下にスクロールする
        automaticallyScrollsToMostRecentMessage = true
        
        // 自分のsenderId, senderDisplayNameを設定
        self.senderId = "user1"
        self.senderDisplayName = "test"
        
        // 吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        // アバターの設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "sample")!, diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "sample")!, diameter: 64)

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
    
    //アイテムごとのセルを返す
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        if messages[indexPath.row].senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.darkGray
        }
        return cell
    }
    
    //アイテムごとにアバター画像を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        //senderId == 自分　だった場合表示しない
        let senderId = messages[indexPath.row].senderId
        
        if senderId == "user1" {
            return nil
        }
        return JSQMessagesAvatarImage.avatar(with: UIImage(named: "sample"))
    }
    
    //アイテムの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    //Sendボタンが押された時に呼ばれる
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        //メッセージを追加
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        self.messages.append(message!)
        
        //メッセージの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessage(animated: true)
        
        //firebaseにデータを送信、保存する

        //キーボードを閉じる
        self.view.endEditing(true)
        
        //textFieldをクリアする
        self.inputToolbar.contentView.textView.text = ""
        
        //テスト返信を呼ぶ
        testRecvMessage()
        
        //saveMessages()
    }
    
    // テスト用 メッセージを返す
    func testRecvMessage() {
        let message = JSQMessage(senderId: "sushi", displayName: "B", text: messages[messages.count-1].text)
        self.messages.append(message!)
        self.finishReceivingMessage(animated: true)
    }
    
    // メッセージの読込/保存
    let messageId = "message1"
    func loadMessages() {
        let defaults  = UserDefaults.standard
        let readdata  = defaults.data(forKey: messageId)
        print(readdata)
    }
    func saveMessages() {
        let defaults = UserDefaults.standard
        defaults.set(self.messages ,forKey: messageId)
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
