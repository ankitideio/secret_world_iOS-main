//
//  BGigDetailModel.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 11/03/24.
//
import Foundation

// MARK: - BusinessGigDetailModel
struct GetUserGigDetailModel: Codable {
    let status: String?
    let message: String?
    let statusCode: Int?
    let data: GetUserGigDetailData?
}

// MARK: - DataClass
struct GetUserGigDetailData: Codable {
    let id: String?
    let status: Int?
    let applyuserID: String?
    let promoCodes: PromoCodes?
    let gig: Giges?
    let appliedParticipants: Int?
    let reviews: [ReviewGigBuser]?
    let isReview: Bool?
    let rating: Double?
    let participantsList: [ParticipantsList]? // Added participants list
    
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
    let startTime:String?
    let category:Category?
    let experience:String?
    let description:String?
    let dressCode:String?
    let isCancellation:Int?
    let paymentMethod:Int?
    let paymentStatus:Int?
    let paymentTerms:Int?
    let personNeeded:Int?
    let safetyTips:String?
    let skills: [CategoryGig]?
    let tools: [String]?
    let address:String?
    let distance:Double?
    enum CodingKeys: String, CodingKey {
        case usertype, name, title, place, serviceDuration, serviceName, startDate
        case lat, long, type, image, participants, totalParticipants, price, about, createdAt, updatedAt, user,startTime,category,experience,description,dressCode,isCancellation,paymentMethod,paymentStatus,paymentTerms,personNeeded,safetyTips,skills,tools,address,distance
    }
}

// MARK: - Category
struct Category: Codable {
    let id, name: String?
  
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
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
    let lat, long: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, gender
        case profilePhoto = "profile_photo"
        case lat, long
    }
}
struct ParticipantsList: Codable {
    let gender, id, profilePhoto,name: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name, gender
        case profilePhoto = "profile_photo"
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



