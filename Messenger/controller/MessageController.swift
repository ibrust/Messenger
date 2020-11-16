//
//  MessageController.swift
//  Messenger
//
//  Created by Field Employee on 11/14/20.
//

import UIKit
import Firebase
import FirebaseDatabase

class MessageController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let reuse_id = "message_cell"
    var messages_array: [Message]  = []
    var sender_email: String? = nil
    var receiver_email: String? = nil
    var number_of_rows: Int = 0
    let database = Database.database().reference()
    
    @IBOutlet weak var table_view_reference: UITableView!
    @IBOutlet weak var message_input_outlet: UITextField!

    @IBAction func back_button_handler(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "return_to_list_segue", sender: nil)
    }
    
    @IBAction func message_send_handler(_ sender: UIButton) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss ZZZZZ"
        let current_date = formatter.string(from: date)
        
        database.child("messages").child(current_date).setValue(["userSending": sender_email, "userReceiving": receiver_email, "message": message_input_outlet.text])
    }
    
    @IBAction func logout_handler(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("logout error")
        }
        performSegue(withIdentifier: "logout_from_message_segue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.database.child("messages").observe(.value, with: { [weak self] (snapshot) in
            guard let self = self else{return}
            let value = snapshot.value as? [String: Any?]
            
            self.messages_array = []
            self.number_of_rows = 0
                        
            for (key, value) in value! {
                let dict = value as? [String: Any?]
                
                guard let email1 = dict?["userSending"] as? String else{return}
                guard let email2 = dict?["userReceiving"] as? String else{return}
                                
                if (email1 == self.sender_email && email2 == self.receiver_email) || (email2 == self.sender_email && email1 == self.receiver_email) {
                    
                    guard let message = dict?["message"] as? String else{return}
                    let message_obj = Message(key, email1, email2, message)
                    self.messages_array.append(message_obj)
                    self.number_of_rows += 1
                }
            }
            self.table_view_reference.reloadData()
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return number_of_rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse_id, for: indexPath) as? Message_Cell ?? Message_Cell()
        
        cell.message_label_outlet.text = messages_array[indexPath.row].message
        cell.name_outlet.text = messages_array[indexPath.row].userSending
        
        if messages_array[indexPath.row].userSending == sender_email {
            cell.message_label_outlet.textAlignment = .right
            cell.name_outlet.textAlignment = .right
        } else {
            cell.message_label_outlet.textAlignment = .left
            cell.name_outlet.textAlignment = .left
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let controller as UserListController:
            controller.login_email = sender_email
        default:
            break
        }
    }
    
}
