//
//  GetBusinessUserModel.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 12/02/24.
//

import Foundation
// MARK: - GetBusinessUserModel
struct GetBusinessUserModel: Codable {
    let status, message: String?
    let statusCode: Int?
    let data: GetBusinessUserDetail?
}

// MARK: - DataClass
struct GetBusinessUserDetail: Codable {
    let userProfile: UserProfiles?
    let serviceCount, gigCount,userRatingCount,postedPopup: Int?
    let UserRating:Double?
    let reviews: [Reviewwe]?
}

// MARK: - Review
struct Reviewwe: Codable {
    let id: String?
    let userID: UserID?
    let businessUserID, comment: String?
    let media: String?
    let starCount: Double?
    let isDeleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case businessUserID = "businessUserId"
        case comment, media, starCount, isDeleted, createdAt, updatedAt
        case v = "__v"
    }
}

// MARK: - UserID
struct UserID: Codable {
    let id, name: String?
    let profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case profilePhoto = "profile_photo"
    }
}

// MARK: - UserProfile
struct UserProfiles: Codable {
    let id, name: String?
    let profilePhoto: String?
    let mobile: Int?
    let businessname: String?
    let coverPhoto: String?
    let gender, about, place: String?
    let services: [Service]?
    let dob: String?
    let openingHours: [OpeningHourr]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case profilePhoto = "profile_photo"
        case mobile, businessname
        case coverPhoto = "cover_photo"
        case gender, about, place
        case services = "Services"
        case dob
        case openingHours = "opening_hours"
    }
}

// MARK: - OpeningHour
struct OpeningHourr: Codable {
    let id, day, starttime, endtime: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case day, starttime, endtime
    }
}

// MARK: - Service
struct Service: Codable {
    let id, name: String?
    let subservicesIDS: [String]?
    let status: Int?
    let isDeleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case subservicesIDS = "subservices_ids"
        case status, isDeleted, createdAt, updatedAt
        case v = "__v"
    }
}

