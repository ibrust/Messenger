//
//  UserListController.swift
//  Messenger
//
//  Created by Field Employee on 11/14/20.
//

import UIKit
import Firebase
import FirebaseDatabase


class UserListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let reuse_id = "custom_cell"
    var number_of_rows = 0
    var login_email: String? = nil
    var users_array: [User] = []
    
    let database = Database.database().reference()
    
    @IBAction func logout_handler(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("logout error")
        }
        performSegue(withIdentifier: "logout_from_list_segue", sender: nil)
    }
    
    @IBOutlet weak var table_view_reference: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.database.child("users").observe(.value, with: { [weak self] (snapshot) in
            guard let self = self else{return}
            guard let response = snapshot.value as? [String: Any?] else{return}
            
            self.users_array = []
            
            for (key, value) in response {
                let dict = value as? [String: Any?]
                let first_name = dict?["firstName"] as? String ?? "-"
                let last_name = dict?["lastName"] as? String ?? "-"
                
                let user_obj = User(first_name, last_name, key)
                
                self.users_array.append(user_obj)
                self.number_of_rows += 1
            }
            
            self.number_of_rows = response.count ?? 0
            self.table_view_reference.reloadData()
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return number_of_rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse_id, for: indexPath) as? Custom_Cell ?? Custom_Cell()
        
        cell.user_email_outlet.text = users_array[indexPath.row].email
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "messenger_segue", sender: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let message_controller = segue.destination as? MessageController
        guard let index = sender as? Int else{return}
        
        // bugged when you come back from detail - the login_email was nil apparently 
        message_controller?.sender_email = safe_email(self.login_email!)
        message_controller?.receiver_email = users_array[index].email
    }

}
