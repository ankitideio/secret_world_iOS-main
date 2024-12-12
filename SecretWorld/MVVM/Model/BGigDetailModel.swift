//
//  BGigDetailModel.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 11/03/24.
//

import Foundation
// MARK: - BGigDetailModel
struct BGigDetailModel: Codable {
    let status, message: String?
    let statusCode: Int?
    let data: GetGigDetailData?
}

// MARK: - DataClass
struct GetGigDetailData: Codable {
    let id, name, title, place: String?
    let lat: Double?
    let status: Int?
    let long: Double?
    let type: String?
    let image: String?
    let participants: String?
    let price,paymentStatus: Int?
    let about,serviceDuration,serviceName,startDate: String?
    let user: UserDetailes?
    let appliedParticipants: Int?
    let reviews: [ReviewGigBuser]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, title, place, lat, status, long, type, image, participants, price, about, user, appliedParticipants, reviews,paymentStatus,serviceDuration,serviceName,startDate
    }
}

// MARK: - Review
struct ReviewGigBuser: Codable {
    let id, gigID, businessUserID: String?
    let comment: String?
    let userID: User?
    let media: String?
    let starCount: Double?
    let isDeleted, isReview: Bool?
    let createdAt, updatedAt: String?
    let v: Int?
    let user: UserDetailes?
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case gigID = "gigId"
        case businessUserID = "businessUserId"
        case comment, media, starCount, isDeleted, isReview, createdAt, updatedAt,user
        case v = "__v"
    }
}

// MARK: - User
struct UserDetailes: Codable {
    let id, name, gender: String?
    let profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, gender
        case profilePhoto = "profile_photo"
    }
}

