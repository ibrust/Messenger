//
//  ViewController.swift
//  Messenger
//
//  Created by Field Employee on 11/12/20.
//

import UIKit
import FirebaseDatabase

class LoginController: UIViewController {

    let database = Database.database().reference()
    
    @IBOutlet weak var email_outlet: UITextField!
    
    @IBOutlet weak var password_outlet: UITextField!
    
    @IBAction func login_button_handler(_ sender: UIButton) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

