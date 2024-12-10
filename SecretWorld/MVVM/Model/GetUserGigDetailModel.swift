//
//  GetUserGigDetailModel.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 12/03/24.
//

import Foundation
// MARK: - GetUserGigDetailModel
struct GetUserGigDetailModel: Codable {
    let status, message: String?
    let statusCode: Int?
    let data: GetUserGigData?
}

// MARK: - DataClass
struct GetUserGigData: Codable {
    let id: String?
    let status: Int?
    let applyuserID: String?
    let promoCodes: PromoCodes?
    let gig: Giges?
    let appliedParticipants: Int?
    let reviews: [Reviews]?
    let isReview: Bool?
    let rating:Double?

    enum CodingKeys: String, CodingKey {
        case id, status
        case applyuserID = "applyuserId"
        case promoCodes, gig, appliedParticipants, rating, reviews, isReview
    }
}

// MARK: - Gig
struct Giges: Codable {
    let usertype, name, title, place: String?
    let lat, long: Double?
    let type: String?
    let image: String?
    let participants, totalParticipants: String?
    let price: Int?
    let about, createdAt, updatedAt: String?
    let user: UserDetailses?
}

// MARK: - User
struct UserDetailses: Codable {
    let id, name, gender: String?
    let profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case id, name, gender
        case profilePhoto = "profile_photo"
    }
}

// MARK: - PromoCodes
struct PromoCodes: Codable {
    let id, gigID, applyuserID: String?
    let status, discount: Int?
    let isViewed, isUsed: Bool?
    let promoCode, expiryTime, createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case gigID = "gigId"
        case applyuserID = "applyuserId"
        case status, discount, isViewed, isUsed, promoCode, expiryTime, createdAt, updatedAt
        case v = "__v"
    }
}

// MARK: - Review
struct Reviews: Codable {
    let id, comment: String?
    let starCount: Double?
    let media: String?
    let createdAt, updatedAt: String?
    let user: UserDetailses?
}
