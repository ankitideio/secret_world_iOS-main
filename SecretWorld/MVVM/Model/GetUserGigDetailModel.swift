//
//  GetUserGigDetailModel.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 12/03/24.
//

import Foundation

// MARK: - GetUserGigDetailModel
struct BusinessGigDetailModel: Codable {
    let status, message: String?
    let statusCode: Int?
    let data: BusinessGigDetailData?
    
}

// MARK: - DataClass
    struct BusinessGigDetailData: Codable {
    let id, name, title, startDate: String?
    let startTime, serviceName, experience, address: String?
    let paymentTerms, paymentMethod: Int?
    let skills: [CategoryGig]?
    let tools: [String]?
    let dressCode: String?
    let personNeeded: Int?
    let description, safetyTips: String?
    let isCancellation: Int?
    let serviceDuration, place: String?
    let lat, long: Double?
    let type: String?
    let image: String?
    let paymentStatus: Int?
    let participants, totalParticipants: String?
    let price, status: Int?
    let about: String?
    let user: Participantzz?
    let appliedParticipants: Int?
    let category: CategoryGig?
    let distance: Double?
    let reviews: [Reviews]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, title, startDate, startTime, serviceName, experience, address, paymentTerms, paymentMethod, skills, tools, dressCode, personNeeded, description, safetyTips, isCancellation, serviceDuration, place, lat, long, type, image, paymentStatus, participants, totalParticipants, price, status, about, user, appliedParticipants, category, distance, reviews
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
    let user: Participantzz?
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

// MARK: - Category
struct CategoryGig: Codable {
    let id, name: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

