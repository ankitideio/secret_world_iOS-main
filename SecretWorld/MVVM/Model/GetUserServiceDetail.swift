//
//  GetUserServiceDetail.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 05/03/24.
//

import Foundation

// MARK: - GetUserServiceDetail
struct GetUserServiceDetail: Codable {
    let status, message: String?
    let statusCode: Int?
    let data: ServiceDetailsData?
}

// MARK: - DataClass
struct ServiceDetailsData: Codable {
    let getBusinessDetails: GetBusinessDetail?
    let allservices: [Allservicees]?
    let serviceImagesArray: [String]?
    let review: [String]?
    let gigs: [GigList]?
}

// MARK: - Allservice
struct Allservicees: Codable {
    let id, serviceName,about: String?
    let price,review: Int?
    let serviceImages: [String]?
    let userCategories: UserCategoriess?
    let rating: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case serviceName, price, serviceImages, userCategories, rating,review,about
    }
}

// MARK: - UserCategories
struct UserCategoriess: Codable {
    let id, categoryName: String?
    let userSubCategories: [UserSubCategoryy]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case categoryName, userSubCategories
    }
}

// MARK: - UserSubCategory
struct UserSubCategoryy: Codable {
    let id, subcategoryName: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case subcategoryName
    }
}

// MARK: - GetBusinessDetail
struct GetBusinessDetail: Codable {
    let id, userID, name,about: String?
    let mobile: Int?
    let profilePhoto: String?
    let businessname: String?
    let coverPhoto, businessID: String?
    let place: String?
    let latitude, longitude: Double?
    let serviceImages: [String]?
    let categoryName: [String]?
    let description: String?
    let rating: Double?
    let typesOfCategoryDetails:[String]?
    let ratingCount,category: Int?
    let openingHours: [OpeningHourer]?
    let businessDeals:[businessDeals]?
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "user_id"
        case name, mobile
        case profilePhoto = "profile_photo"
        case businessname
        case coverPhoto = "cover_photo"
        case businessID = "business_id"
        case place, latitude, longitude, serviceImages, description, rating, openingHours,ratingCount,categoryName,about,category,typesOfCategoryDetails,businessDeals
    }
}

// MARK: - OpeningHour
struct OpeningHourer: Codable {
    let day: String?
    let status: String?
    let starttime, endtime: String?
}



// MARK: - Gig
struct GigList: Codable {
    let id, userID, usertype, name: String?
    let title: String?
    let place: String?
    let lat, long: Double?
    let type: String?
    let image: String?
    let participants: String?
    let price,review,userRatingCount: Int?
    let about: String?
    let isDeleted: Bool?
    let createdAt, updatedAt: String?
    let v, rating,UserRating: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case usertype, name, title, place, lat, long, type, image, participants, price, about, isDeleted, createdAt, updatedAt,UserRating,userRatingCount
        case v = "__v"
        case rating, review
    }
}

