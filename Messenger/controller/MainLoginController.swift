//
//  ViewController.swift
//  Messenger
//
//  Created by Field Employee on 11/12/20.
//

import UIKit
import FirebaseDatabase

class MainLoginController: UIViewController {

    let database = Database.database().reference()
    var login_container: LoginContainer? = nil
    var registration_container: RegistrationContainer? = nil
    
    @IBOutlet weak var registration_main_view: UIView!
    
    @IBOutlet weak var login_main_view: UIView!
    
    @IBAction func segmented_control_handler(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            login_container?.view.isHidden = false
            login_main_view.isUserInteractionEnabled = true
            registration_container?.view.isHidden = true
            registration_main_view.isUserInteractionEnabled = false
        case 1:
            login_container?.view.isHidden = true
            login_main_view.isUserInteractionEnabled = false
            registration_container?.view.isHidden = false
            registration_main_view.isUserInteractionEnabled = true
        default:
            break
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                
        switch segue.destination {
        case let container as LoginContainer:
            container.delegate = self
            self.login_container = container
        case let container as RegistrationContainer:
            container.delegate = self
            self.registration_container = container
        default:
            break
        }
        
    }

}

