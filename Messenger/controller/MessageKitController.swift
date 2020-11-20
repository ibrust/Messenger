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

class Message_Kit_Controller : MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    var sender_email: String? = nil
    var receiver_email: String? = nil
    let database = Database.database().reference()
    
    var messages: [MessageType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure message collection view
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true
        
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .purple
        messageInputBar.sendButton.setTitleColor(.green, for: .normal)
        messageInputBar.sendButton.setTitleColor(.red, for: .highlighted)
        
        self.messages = []
        
        DispatchQueue.global(qos: .userInitiated).async{
            self.database.child("messages").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                guard let self = self else{return}
                let value = snapshot.value as? [String: Any?]
                
                for (key, value) in value! {
                    let dict = value as? [String: Any?]
                    guard let email1 = dict?["userSending"] as? String else{continue}
                    guard let email2 = dict?["userReceiving"] as? String else{continue}
                    
                    if (email1 == self.sender_email && email2 == self.receiver_email) || (email2 == self.sender_email && email1 == self.receiver_email) {
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                        let message_date = formatter.date(from: key) ?? Date()
                        
                        guard let message = dict?["message"] as? String else{continue}
                        let message_obj = Message(sender: Sender(senderId: email1, displayName: email1), messageId: "\(self.messages.count + 1)", sentDate: message_date, kind: .text("\(message)"))
                        self.messages.append(message_obj)
                    }
                }
                
                self.messages.sort {
                    $0.sentDate < $1.sentDate
                }
                
                print("MESSAGES: ", self.messages)
                
                DispatchQueue.main.async{
                    self.messagesCollectionView.reloadData()
                    
                    // need to fix the scroll to bottom bug if the section isn't actually at the bottom of the screen yet....? why is that happening?
                    if self.is_last_message_visible() == false{
                        self.messagesCollectionView.scrollToBottom(animated: true)
                    }
                }
            })
            self.database.child("messages").observe(.value, with: { [weak self] (snapshot) in
                guard let self = self else{return}
                let value = snapshot.value as? [String: Any?]
                
                for (key, value) in value! {
                    
                    // you should search for whether the message is unique here...
                    // use the date to do the search... right?
                    // if it's unique, add it to the array...
                    // what if two messages are sent at the same time?
                    // verify the search? I don't know.
                    // like you could look for duplicate messages and discard them
                    // ...? 
                    
                }
            })
        }
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
            return custom_string
        }
        return nil
    }
    
    // get something popping up briefly or something like this
    func didTapAvatar(in cell: MessageCollectionViewCell){
        print("tapped avatar")
    }
    
    func is_last_message_visible() -> Bool {
        guard !messages.isEmpty else {return false}
        let last_index_path = IndexPath(item: 0, section: messages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(last_index_path)
    }
    
    // input bar accessory delegate functions
    @objc func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let text = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: text.length)
        text.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
            
            let substring = text.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("autocompleted: ", substring, " with context: ", context ?? [])
        }
        
        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        
        inputBar.inputTextView.resignFirstResponder()
        
        DispatchQueue.main.async { [weak self] in
            for component in components {
                if let input_string = component as? String {
                    
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    let current_date = formatter.string(from: date)
                    
                    self?.database.child("messages").child(current_date).setValue(["userSending": self?.sender_email, "userReceiving": self?.receiver_email, "message": input_string])
                    
                    let sender = Sender(senderId: self?.sender_email ?? "", displayName: self?.sender_email ?? "")
                    let message_obj = Message(sender: sender, messageId: "\(self?.messages.count ?? 0) + 1)", sentDate: Date(), kind: .text(input_string))
                    
                    self?.messages.append(message_obj)
                }
            }
            inputBar.sendButton.stopAnimating()
            inputBar.inputTextView.placeholder = "enter text"
            self?.messagesCollectionView.reloadDataAndKeepOffset()
            if self?.is_last_message_visible() == false {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
}


