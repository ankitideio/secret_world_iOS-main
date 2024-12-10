//
//  ChatModel.swift
//  SecretWorld
//
//  Created by meet sharma on 15/04/24.
//

import Foundation

// MARK: - ChatModel
struct ChatModel: Codable {
    let messages: [Message]?
    let userBlocked: Bool?
    let blockedByUser:Bool?
    let userOnline:Bool?
}

// MARK: - Message
struct Message: Codable {
    let id: String?
    let senderID: String?
    let media: [String]?
    var messageDate:Date?
    var createdAt: String?
    let sender, recipient: Recipient?
    let isRead: Int?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case senderID = "senderId"
        case media, createdAt, sender, recipient, isRead, message,messageDate
    }
    init(id: String?, senderID: String?, media: [String]?, createdAt: String?, sender: Recipient?, recipient: Recipient?, isRead: Int?, message: String?,messageDate: String?) {
           self.id = id
           self.senderID = senderID
           self.media = media
           self.createdAt = createdAt
           self.sender = sender
           self.recipient = recipient
           self.isRead = isRead
           self.message = message
           let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
           guard let date = dateFormatter.date(from: messageDate ?? "") else {
                   fatalError("Failed to parse message date.")
            }
        self.messageDate = date
         
       }
}



// MARK: - Recipient
struct Recipient: Codable {
    let id: String?
    let name: String?
    let profilePhoto: String?
    let role: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case profilePhoto = "profile_photo"
        case role
    }
}
