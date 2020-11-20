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
        
        self.delegate?.login_email = email_address
        
        Auth.auth().createUser(withEmail: email_address, password: password) { [weak self] authResult, error in
            guard let self = self else{return}
            if let error = error as NSError? {
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
                let user_object = User(first_name, last_name, email_address)
                self.upload_user_object(user_object)
                
                self.delegate?.performSegue(withIdentifier: "user_list_segue", sender: nil)
                
            }
        }
    }
    
    func upload_user_object(_ user_struct: User){
        self.delegate?.database.child("users").child(user_struct.email).setValue(["firstName": user_struct.firstName, "lastName": user_struct.lastName])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
