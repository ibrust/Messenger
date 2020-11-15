//
//  LoginContainer.swift
//  Messenger
//
//  Created by Field Employee on 11/13/20.
//

import UIKit
import Firebase
import FirebaseDatabase

class LoginContainer: UIViewController {

    @IBOutlet var login_container_view_outlet: UIView!
    
    @IBOutlet weak var login_outlet: UITextField!
    
    @IBOutlet weak var password_outlet: UITextField!
    
    @IBAction func login_button_handler(_ sender: UIButton) {
        
        guard let login_email = login_outlet.text else{return}
        guard let password = password_outlet.text else{return}
        if is_valid_email(login_email) == false{return}     // display some sort of error message here
        if is_valid_password(password) == false{return}
        
        self.delegate?.login_email = login_email
        
        Auth.auth().signIn(withEmail: login_email, password: password) { (authResult, error) in
            
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code){
                case .operationNotAllowed:  // indicates email/password accounts are not enabled
                    break
                case .userDisabled:         // indicates user account has been disabled by admin
                    break
                case .wrongPassword:
                    break
                case .invalidEmail:
                    break
                default:
                    break
                }
            } else {
                
                self.delegate?.performSegue(withIdentifier: "user_list_segue", sender: nil)
            }
            
        }
        
    }
    
    weak var delegate: MainLoginController? = nil 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
