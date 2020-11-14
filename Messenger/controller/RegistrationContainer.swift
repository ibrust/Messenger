//
//  RegistrationContainer.swift
//  Messenger
//
//  Created by Field Employee on 11/13/20.
//

import UIKit
import Firebase
import FirebaseDatabase

class RegistrationContainer: UIViewController {

    @IBOutlet var registration_container_view_outlet: UIView!
    
    @IBOutlet weak var first_name_outlet: UITextField!
    
    @IBOutlet weak var last_name_outlet: UITextField!
    
    @IBOutlet weak var email_outlet: UITextField!
    
    @IBOutlet weak var password_outlet: UITextField!
    weak var delegate: MainLoginController? = nil
    
    
    @IBAction func register_button_handler(_ sender: UIButton) {
        guard let first_name = first_name_outlet.text else{return}
        guard let last_name = last_name_outlet.text else{return}
        guard let email_address = email_outlet.text else{return}
        guard let password = password_outlet.text else{return}
        if is_valid_email(email_address) == false{return}
        if is_valid_password(password) == false{return}
        
        Auth.auth().createUser(withEmail: email_address, password: password) { authResult, error in
            if let error = error as? NSError {
                switch AuthErrorCode(rawValue: error.code){
                case .emailAlreadyInUse:
                    break
                case .invalidEmail:
                    break
                case .weakPassword:
                    break
                default:
                    break
                }
            } else {
                let new_user_info = Auth.auth().currentUser
                let stored_email = new_user_info?.email
                
                // put some code to actually create a user database object here 
                
            }
        }
        
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
