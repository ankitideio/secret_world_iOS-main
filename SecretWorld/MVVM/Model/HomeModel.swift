//
//  HomeModel.swift
//  SecretWorld
//
//  Created by meet sharma on 22/04/24.
//

import Foundation


// MARK: - HomeModel
struct HomeModel: Codable {
    let data: HomeData?
}

// MARK: - HomeData
struct HomeData: Codable {
    let filteredItems: [FilteredItem]?
    let paymentStatus: Int?
    let completedGigs: [CompletedGig]?
    let notificationsCount: Int?
}

// MARK: - CompletedGig
struct CompletedGig: Codable {
    let id, userID, usertype, name: String?
    let title, place: String?
    let lat, long: Double?
    let type: String?
    let image: String?
    let paymentStatus: Int?
    let participants, totalParticipants: String?
    let price, status,appliedStatus: Int?
    let about: String?
    let isDeleted, isCancelled, isCompleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case usertype, name, title, place, lat, long, type, image, paymentStatus, participants, totalParticipants, price, status, about, isDeleted, isCancelled, isCompleted, createdAt, updatedAt,appliedStatus
        case v = "__v"
    }
}

// MARK: - FilteredItem
struct FilteredItem: Codable,Equatable {
    let id, userID: String?
    let name: String?
    let title: String?
    let place: String?
    let lat, long: Double?
    let latitude, longitude: Double?
    let type: String?
    let image: String?
    let categoryName:[String]?
    let paymentStatus,userRatingCount: Int?
    let participants: String?
    let price, status,appliedStatus,isReady: Int?
    let about: String?
    let isDeleted, isCompleted: Bool?
    let seen: Int?
    let locationType,groupId: String?
    let myGigs: Bool?
    let profilePhoto: String?
    let businessname: String?
    let businessID, coverPhoto: String?
    let openingHours: [OpeningHourHome]?
    let businessLogo: String?
    let description: String?
    let addProducts: [AddProductHome]?
    let user: UserDetailz?
    let startDate, endDate: String?
    let myPopUp: Bool?
    let UserRating: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case name, title, place, lat, long, type, image, paymentStatus, participants, price, status, about, isDeleted, isCompleted, seen, locationType, myGigs,appliedStatus,isReady,groupId,userRatingCount,UserRating,categoryName,user,latitude,longitude
        case profilePhoto = "profile_photo"
        case businessname
        case businessID = "business_id"
        case coverPhoto = "cover_photo"
        case openingHours = "opening_hours"
        case businessLogo = "business_logo"
        case description, addProducts, startDate, endDate, myPopUp
      
    }
}

// MARK: - AddProduct
struct AddProductHome: Codable ,Equatable{
    let productName: String?
    let price: Int?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case productName, price
        case id = "_id"
    }
}
// MARK: - User
struct UserDetailz: Codable,Equatable {
    let name: String
}
// MARK: - OpeningHour
struct OpeningHourHome: Codable ,Equatable{
    let day: String?
    let starttime, endtime: String?
}
