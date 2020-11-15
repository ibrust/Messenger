//
//  DatabaseObjects.swift
//  Messenger
//
//  Created by Field Employee on 11/14/20.
//

import Foundation

struct User {
    var firstName: String
    var lastName: String
    var email: String
 
    init(_ firstname: String, _ lastname: String, _ email: String){
        self.firstName = firstname
        self.lastName = lastname
        self.email = safe_email(email)
    }
}

struct Message {
    var date: String
    var message: String
    var userReceiving: String
    var userSending: String
    
    init(_ date: String, _ usersending: String, _ userreceiving: String, _ message: String){
        self.userSending = safe_email(usersending)
        self.userReceiving = safe_email(userreceiving)
        self.message = message
        self.date = date
    }
}

func safe_email(_ email: String) -> String {
    var safe_email = email.replacingOccurrences(of: ".", with: "-")
    safe_email = safe_email.replacingOccurrences(of: "@", with: "-")
    return safe_email
}

/*
func upload_new_message(message: MessageContainer){
    database.child("messages").child(message.dateTime).setValue(["userSending": message.userSending, "userReceiving": message.userReceiving, "message": message.message])
}
*/
