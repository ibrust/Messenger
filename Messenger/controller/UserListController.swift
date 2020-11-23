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
    var login_email: String? = nil
    var users_array: [User] = []
    var avatars_array: [UIImage] = []
    var sender_avatar: UIImage? = nil
    
    let database = Database.database().reference()
    
    @IBAction func logout_handler(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: {
            do {
                try Auth.auth().signOut()
            } catch {
                print("logout error")
            }
        })
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
                let new_avatar = Custom_Avatars.shared.get_avatar()
                self.avatars_array.append(new_avatar)
                if safe_email(self.login_email ?? "") == safe_email(key) {
                    print("MATCH")
                    self.sender_avatar = new_avatar
                }
            }
            self.table_view_reference.reloadData()
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users_array.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse_id, for: indexPath) as? Custom_Cell ?? Custom_Cell()
        
        cell.user_email_outlet.text = users_array[indexPath.row].email
        cell.name_outlet.text = users_array[indexPath.row].firstName + " " + users_array[indexPath.row].lastName
        cell.image_outlet.image = avatars_array[indexPath.row]
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = color_literals[0]
            cell.user_email_outlet.backgroundColor = color_literals[9]
            cell.name_outlet.backgroundColor = color_literals[9]
            cell.name_outlet.textColor = color_literals[10]
            cell.user_email_outlet.textColor = color_literals[10]
        } else {
            cell.contentView.backgroundColor = color_literals[9]
            cell.user_email_outlet.backgroundColor = color_literals[0]
            cell.name_outlet.backgroundColor = color_literals[0]
            cell.name_outlet.textColor = color_literals[11]
            cell.user_email_outlet.textColor = color_literals[11]
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "message_kit_segue", sender: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let login_email = self.login_email else {return}
        guard let message_kit_controller = segue.destination as? Message_Kit_Controller else {return}
        guard let index = sender as? Int else {return}
        
        message_kit_controller.sender_email = safe_email(login_email)
        message_kit_controller.receiver_email = users_array[index].email
        message_kit_controller.sender_avatar = sender_avatar
        message_kit_controller.receiver_avatar = avatars_array[index]
    }
}
