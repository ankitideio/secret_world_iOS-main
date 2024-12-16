//
//  GetUserGigDetailModel.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 12/03/24.
//

import Foundation

// MARK: - GetUserGigDetailModel
struct GetUserGigDetailModel: Codable {
    let status: String?
    let message: String?
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
    let rating: Double?
    let participantsList: [Participantzz]? // Added participants list
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case applyuserID = "applyuserId"
        case promoCodes, gig, appliedParticipants, rating, reviews, isReview, participantsList
    }
}

// MARK: - Gig
struct Giges: Codable {
    let usertype: String?
    let name: String?
    let title: String?
    let place: String?
    let serviceDuration: String?
    let serviceName: String?
    let startDate: String?
    let lat: Double?
    let long: Double?
    let type: String?
    let image: String?
    let participants: String?
    let totalParticipants: String?
    let price: Int?
    let about: String?
    let createdAt: String?
    let updatedAt: String?
    let user: UserDetailses?
    
    enum CodingKeys: String, CodingKey {
        case usertype, name, title, place, serviceDuration, serviceName, startDate
        case lat, long, type, image, participants, totalParticipants, price, about, createdAt, updatedAt, user
    }
}

// MARK: - User
struct UserDetailses: Codable {
    let id: String?
    let name: String?
    let gender: String?
    let profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case id, name, gender
        case profilePhoto = "profile_photo"
    }
}

// MARK: - PromoCodes
struct PromoCodes: Codable {
    let id: String?
    let gigID: String?
    let applyuserID: String?
    let status: Int?
    let discount: Int?
    let isViewed: Bool?
    let isUsed: Bool?
    let promoCode: String?
    let expiryTime: String?
    let createdAt: String?
    let updatedAt: String?
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
    let id: String?
    let comment: String?
    let starCount: Double?
    let media: String?
    let createdAt: String?
    let updatedAt: String?
    let user: UserDetailses?
}

// MARK: - Participant
struct Participantzz: Codable {
    let gender: String?
    let id: String?
    let name: String?
    let profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case gender, id, name
        case profilePhoto = "profile_photo"
    }
}
