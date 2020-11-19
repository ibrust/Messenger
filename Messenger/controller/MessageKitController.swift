//
//  MessageKitController.swift
//  Messenger
//
//  Created by Field Employee on 11/18/20.
//

import UIKit
import MessageKit
import FirebaseDatabase
import InputBarAccessoryView

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class Message_Kit_Controller : MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    var sender_email: String? = nil
    var receiver_email: String? = nil
    let database = Database.database().reference()
    
    var messages: [MessageType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messages = []
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        self.database.child("messages").observe(.value, with: { [weak self] (snapshot) in
            guard let self = self else{return}
            let value = snapshot.value as? [String: Any?]
                        
            for (key, value) in value! {
                let dict = value as? [String: Any?]
                
                guard let email1 = dict?["userSending"] as? String else{continue}
                guard let email2 = dict?["userReceiving"] as? String else{continue}
                                
                if (email1 == self.sender_email && email2 == self.receiver_email) || (email2 == self.sender_email && email1 == self.receiver_email) {
                    
                    guard let message = dict?["message"] as? String else{continue}
                    let message_obj = Message(sender: Sender(senderId: email1, displayName: email1), messageId: "\(self.messages.count + 1)", sentDate: Date(), kind: .text("\(message)"))
                    self.messages.append(message_obj)
                }
            }
            self.messagesCollectionView.reloadData()
        })
    }
    
    func currentSender() -> SenderType {
        return Sender(senderId: sender_email ?? "-", displayName: sender_email ?? "-")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

extension Message_Kit_Controller {
    // adjut the colors for these 3 functions
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .purple : .yellow
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .orange : .blue
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = Avatar(image: UIImage(systemName: "star"), initials: "IR")
        avatarView.set(avatar: avatar)
    }
    
    
    // do these 2 functions support links & other things in the text? not sure, test it later
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        switch detector{
        case .hashtag, .mention:
            return [.foregroundColor: UIColor.blue]
        default:
            return MessageLabel.defaultAttributes
        }
    }
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    
    // works - but play around with different styles a little bit to see if there's something else that looks cool
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    
    // ?? not working - but not because this function is wrong, something else in the rest of the program is needed to get it working apparently
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            let custom_string = NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            print("STRING: ", custom_string)
            return custom_string
        }
        return nil
    }
    
    // get something popping up briefly or something like this
    func didTapAvatar(in cell: MessageCollectionViewCell){
        print("tapped avatar")
    }
    
}


