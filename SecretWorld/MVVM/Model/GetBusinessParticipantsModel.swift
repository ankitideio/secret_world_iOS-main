//
//  GetBusinessParticipantsModel.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 12/03/24.
//

import Foundation
// MARK: - GetBusinessParticipantsModel
struct GetBusinessParticipantsModel: Codable {
    let status, message: String?
    let statusCode: Int?
    let data: GetBusinessPaticipantsData?
}

// MARK: - DataClass
struct GetBusinessPaticipantsData: Codable {
    let user: [UserDetaills]?
}

// MARK: - User
struct UserDetaills: Codable {
    let id: String?
    let status: Int?
    let message: String?
    let image: String?
    let title, name,userId,applyuserId: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case status, message, image, title, name,userId,applyuserId
    }
}
