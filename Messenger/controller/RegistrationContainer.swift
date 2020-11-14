//
//  RegistrationContainer.swift
//  Messenger
//
//  Created by Field Employee on 11/13/20.
//

import UIKit

class RegistrationContainer: UIViewController {

    @IBOutlet var registration_container_view_outlet: UIView!
    
    @IBOutlet weak var first_name_outlet: UITextField!
    
    @IBOutlet weak var last_name_outlet: UITextField!
    
    @IBOutlet weak var email_outlet: UITextField!
    
    weak var delegate: MainLoginController? = nil 
    
    
    @IBAction func register_button_handler(_ sender: UIButton) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
