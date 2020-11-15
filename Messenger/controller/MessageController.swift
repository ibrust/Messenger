//
//  MessageController.swift
//  Messenger
//
//  Created by Field Employee on 11/14/20.
//

import UIKit
import FirebaseDatabase

class MessageController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table_view_reference: UITableView!

    @IBOutlet weak var message_input_outlet: UITextField!
    
    let reuse_id = "message_cell"
    var messages_array: [Message]  = []
    var sender_email: String? = nil
    var receiver_email: String? = nil
    var number_of_rows: Int = 0
    let database = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("sender email: ", sender_email, "receiver email: ", receiver_email)
        
        self.database.child("messages").observe(.value, with: { [weak self] (snapshot) in
            guard let self = self else{return}
            let value = snapshot.value as? [String: Any?]
            
            self.messages_array = []
            self.number_of_rows = 0
                        
            for (key, value) in value! {
                let dict = value as? [String: Any?]
                                
                if dict?["userSending"] as? String == self.sender_email && dict?["userReceiving"] as? String == self.receiver_email {
                    
                    guard let message = dict?["message"] as? String else{return}
                    print("1")
                    guard let sender_email = self.sender_email else{return}
                    print("2")
                    guard let receiver_email = self.receiver_email else{return}
                    print("3")
                    
                    let message_obj = Message(key, sender_email, receiver_email, message)
                
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
        
        print("INDEX PATH IS: ", indexPath.row)
        cell.message_label_outlet.text = messages_array[indexPath.row].message
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
