//
//  DMText.swift
//  iMessageHistory
//
//  Created by Ramon Amini on 4/15/21.
//

import UIKit

struct DMText {
    var date: String
    var isUser: UIImage
    var phoneNumber: String
    var message: String
    
    init(text: DMText) {
        date = text.date
        isUser = text.isUser
        phoneNumber = text.phoneNumber
        message = text.message
    }
    
    init(date: String, isUser: String, phoneNumber: String, message: String) {
        self.date = date
        if isUser == "0" {
            self.isUser = UIImage(systemName: "person")!
        }
        else {
            self.isUser = UIImage(systemName: "person.fill")!
        }
        self.phoneNumber = phoneNumber
        self.message = message
    }
}
