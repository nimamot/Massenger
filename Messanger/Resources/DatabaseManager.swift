//
//  DatabaseManager.swift
//  Messanger
//
//  Created by Nima on 8/14/20.
//  Copyright © 2020 Nima. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}

// Mark : - Account Managment

extension DatabaseManager{
    
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        database.child(email).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
        
    }
    
    ///insert new user to database
    public func insertUser(with user: ChatAppUser) {
           database.child(user.emailAddress).setValue([
               "first_name": user.firstName,
               "last_name": user.lastName
           ])
       }

}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    // let profilePictureUrl: String
}
