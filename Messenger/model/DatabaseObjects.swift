//
//  DatabaseObjects.swift
//  Messenger
//
//  Created by Field Employee on 11/14/20.
//

import UIKit

let color_literals: [UIColor] = [#colorLiteral(red: 0.7490196078, green: 0.6431372549, blue: 0.1411764706, alpha: 1), #colorLiteral(red: 0.4083473384, green: 0.1265535951, blue: 0.1434190869, alpha: 1), #colorLiteral(red: 0.8470588235, green: 0.3843137255, blue: 0.05490196078, alpha: 1), #colorLiteral(red: 0.3843137255, green: 0.8823529412, blue: 0.8156862745, alpha: 1), #colorLiteral(red: 0.3450980392, green: 0.8274509804, blue: 0.8509803922, alpha: 1), #colorLiteral(red: 0.7019607843, green: 0.7725490196, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.7960784314, green: 0.9529411765, blue: 0.937254902, alpha: 1), #colorLiteral(red: 0.6549019608, green: 0.4588235294, blue: 0.06666666667, alpha: 1)]

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

struct Custom_Message {
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



