//
//  utility_functions.swift
//  Messenger
//
//  Created by Field Employee on 11/13/20.
//

import Foundation


func is_valid_email(_ email: String) -> Bool {
    let email_regex = "[A-Z0-9a-z._%+=]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let email_predicate = NSPredicate(format:"SELF MATCHES %@", email_regex)
    return email_predicate.evaluate(with: email)
}

func is_valid_password(_ password: String) -> Bool {
    let min_password_length = 6
    return password.count >= min_password_length
}
