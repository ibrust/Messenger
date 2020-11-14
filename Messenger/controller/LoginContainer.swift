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
        if is_valid_email(login_email) == false{return}
        if is_valid_password(password) == false{return}
        
        Auth.auth().signIn(withEmail: login_email, password: password) { (authResult, error) in
            
            if let error = error as? NSError {
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
                let user_info = Auth.auth().currentUser
                let logged_in_email = user_info?.email
            }
            
        }
        
    }
    
    weak var delegate: MainLoginController? = nil 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
