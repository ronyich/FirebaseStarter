//
//  Author.swift
//  Grocr
//
//  Created by Ron Yi on 2018/11/19.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase

struct Author {

    let uid: String
    let email: String
    //var userName: String
    
    init(authData: Firebase.User) {
        uid = authData.uid
        email = authData.email ?? ""
    }

    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
        //self.userName = userName
    }

}
