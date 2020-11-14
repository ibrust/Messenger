//
//  LoginContainer.swift
//  Messenger
//
//  Created by Field Employee on 11/13/20.
//

import UIKit
import FirebaseDatabase

class LoginContainer: UIViewController {

    @IBOutlet var login_container_view_outlet: UIView!
    
    @IBOutlet weak var login_outlet: UITextField!
    
    @IBOutlet weak var password_outlet: UITextField!
    
    @IBAction func login_button_handler(_ sender: UIButton) {
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
