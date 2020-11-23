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
 
    var sender_avatar: UIImage? = nil
    var receiver_avatar: UIImage? = nil 
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: color_literals[7]])
        }
        return nil
    }
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 37.5 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? 37.5 : 0
        }
    }
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1), NSAttributedString.Key.foregroundColor: color_literals[7]])
        }
        return nil
    }
    
    var sender_email: String? = nil
    var receiver_email: String? = nil
    let database = Database.database().reference()
    let max_letter_count = 2000
    
    var messages: [MessageType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        
        configure_collection_view()
        configure_input_bar()

        self.messages = []
        
        DispatchQueue.global(qos: .userInitiated).async{
            self.database.child("messages").observe(.value, with: { [weak self] (snapshot) in
                guard let self = self else{return}
                let value = snapshot.value as? [String: Any?]
                
                for (key, value) in value! {
                    let dict = value as? [String: Any?]
                    guard let email1 = dict?["userSending"] as? String else{continue}
                    guard let email2 = dict?["userReceiving"] as? String else{continue}
                    
                    if (email1 == self.sender_email && email2 == self.receiver_email) || (email2 == self.sender_email && email1 == self.receiver_email) {
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                        guard let message_date = formatter.date(from: key) else {
                            continue
                        }
                        
                        var duplicate_date = false
                        for old_message in self.messages {
                            if message_date.timeIntervalSince1970 == old_message.sentDate.timeIntervalSince1970 {
                                duplicate_date = true
                                break
                            }
                        }
                        if duplicate_date == true {
                            continue
                        }
                        
                        guard let message = dict?["message"] as? String else{continue}
                        let message_obj = Message(sender: Sender(senderId: email1, displayName: email1), messageId: "\(self.messages.count + 1)", sentDate: message_date, kind: .text("\(message)"))
                        self.messages.append(message_obj)
                    }
                }
                
                self.messages.sort {
                    $0.sentDate < $1.sentDate
                }
                
                DispatchQueue.main.async{
                    self.messagesCollectionView.reloadData()
                    
                    if self.is_last_message_visible() == false{
                        self.messagesCollectionView.scrollToBottom(animated: true)
                    }
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
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? color_literals[7] : color_literals[6]
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? color_literals[0] : color_literals[3]
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        var avatar: Avatar
        if message.sender.senderId == self.sender_email {
            avatar = Avatar(image: sender_avatar, initials: "")
        } else {
            avatar = Avatar(image: receiver_avatar, initials: "")
        }
        
        avatarView.set(avatar: avatar)
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = color_literals[1].cgColor
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        switch detector{
        case .hashtag, .mention:
            return [.foregroundColor: color_literals[4]]
        default:
            return MessageLabel.defaultAttributes
        }
    }
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .date, .transitInformation, .mention, .hashtag]
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTailOutline(color_literals[1], tail, .curved)
    }
    
    // send message handler
    @objc func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
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
                }
            }
            
            inputBar.sendButton.stopAnimating()
            inputBar.inputTextView.placeholder = ""
            self?.messagesCollectionView.reloadDataAndKeepOffset()
            if self?.is_last_message_visible() == false {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
}


// private helper functions
extension Message_Kit_Controller {
    private func is_last_message_visible() -> Bool {
        guard !messages.isEmpty else {return false}
        let last_index_path = IndexPath(item: 0, section: messages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(last_index_path)
    }
    
    private func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].sender.senderId == messages[indexPath.section + 1].sender.senderId
    }
    
    private func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    private func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].sender.senderId == messages[indexPath.section - 1].sender.senderId
    }
    private func configure_collection_view(){
        messagesCollectionView.backgroundColor = color_literals[1]
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 17.5, right: 18)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        layout?.setMessageOutgoingAvatarSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingMessagePadding(UIEdgeInsets(top: -17.5, left: 18, bottom: 17.5, right: -18))
        
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
        layout?.setMessageOutgoingAccessoryViewPosition(.messageBottom)
        
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: 17.5, right: 0)))
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -17.5, left: -18, bottom: 17.5, right: 18))
        
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
    }
    
    private func configure_input_bar(){
        messageInputBar.backgroundView.backgroundColor = color_literals[3]
        messageInputBar.inputTextView.tintColor = color_literals[1]
        messageInputBar.inputTextView.backgroundColor = color_literals[0]
        messageInputBar.inputTextView.placeholderLabel.text = ""
        messageInputBar.inputTextView.textColor = color_literals[7]
        messageInputBar.inputTextView.layer.borderColor = color_literals[2].cgColor
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor.white
        messageInputBar.sendButton.image = UIImage(named:
            "mailbox")
        
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        let charCountButton = InputBarButtonItem()
            .configure {
                $0.title = "0/\(max_letter_count)"
                $0.contentHorizontalAlignment = .right
                $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                $0.setSize(CGSize(width: 50, height: 25), animated: false)
            }.onTextViewDidChange { [weak self] (item, textView) in
                var isOverLimit = false
                if let self = self {
                    item.title = "\(textView.text.count)/\(self.max_letter_count)"
                    isOverLimit = textView.text.count > self.max_letter_count
                }
                item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit
                if isOverLimit {
                    item.inputBarAccessoryView?.sendButton.isEnabled = false
                }
                let title_color = isOverLimit ? UIColor.red : color_literals[7]
                item.setTitleColor(title_color, for: .normal)
        }
        let bottomItems = [.flexibleSpace, charCountButton]
        
        messageInputBar.padding.bottom = 8
        messageInputBar.middleContentViewPadding.right = -38
        messageInputBar.inputTextView.textContainerInset.bottom = 8
        
        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = color_literals[2]
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = UIColor.white
                })
        }
    }
}


