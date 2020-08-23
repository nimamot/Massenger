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
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

// Mark : - Account Managment

extension DatabaseManager{
    
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
        
    }
    
    ///insert new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
            ], withCompletionBlock: { error, _ in
                guard error == nil else{
                    print("failed to write to database")
                    completion(false)
                    return
                }
                
                
                self.database.child("users").observeSingleEvent(of: .value,with: { snapshot in
                    if var usersCollection = snapshot.value as? [[String:String]] {
                        //append to user dictenery
                        let newElement = [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                            
                        ]
                        usersCollection.append(newElement)
                        
                        self.database.child("users").setValue(usersCollection, withCompletionBlock: {error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            
                            completion(true)
                        })
                    }
                    else {
                        //creat the erray
                        let newCollection: [[String: String]] = [
                            [
                                "name": user.firstName + " " + user.lastName,
                                "email": user.safeEmail
                            ]
                        ]
                        
                        self.database.child("users").setValue(newCollection, withCompletionBlock: {error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            
                            completion(true)
                        })
                    }
                })
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
        
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
}



// Mark: - SENDING MESSEGAES/ CONVOS
extension DatabaseManager {
    //creat a new convo with target users and first message
    public func CreatNewConversation(with otherUsersEmail: String, name: String, firstMessage: Message, completion: @escaping(Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else{
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dataString = ChatViewController.dateFormater.string(from: messageDate)
            
            var message = ""
            switch firstMessage.kind {case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_ \(firstMessage.messageId)"
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_User_email": otherUsersEmail,
                "name": name,
                "latest_message": [
                    "date": dataString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // COnversation exsist for the user
                
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                    
                })
            }
            else {
                
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self.finishCreatingConversation(name: name,
                                                    conversationID: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                    
                })
            }
        })
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        let messageDate = firstMessage.sentDate
        let dataString = ChatViewController.dateFormater.string(from: messageDate)
        var message = ""
        switch firstMessage.kind {case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dataString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
            
        ]
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding convo: \(conversationID)")
        
        database.child("\(conversationID)").setValue( value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
        
    }
    
    //fetches and returns all convos for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let otherUserEmail = dictionary["other_User_email"] as? String,
                    let latestMessage = dictionary["latest_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else{
                        return nil
                }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))
        })
    }
    //gets all messages for all convos
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                    let isRead = dictionary["is_read"] as? Bool,
                    let messageID = dictionary["id"] as? String,
                    let content = dictionary["content"] as? String,
                    let senderEmail = dictionary["sender_email"] as? String,
                    let dateString = dictionary["date"] as? String,
                    let type = dictionary["type"] as? String,
                    let date = ChatViewController.dateFormater.date(from: dateString) else {
                        print("missing something in here")
                        return nil
                }
                
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: .text(content))
            })
            
            completion(.success(messages))
        })
        
    }
    
    //sends a mesage with convo and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
    
}

