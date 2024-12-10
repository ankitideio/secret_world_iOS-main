//
//  PopupDetailModel.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 10/04/24.
//

import Foundation
// MARK: - PopupDetailModel
struct PopupDetailModel: Codable {
    let status, message: String?
    let statusCode: Int?
    let data: PopupDetailData?
}

// MARK: - DataClass
struct PopupDetailData: Codable {
    let id, name, usertype,place: String?
    let businessLogo,image: String?
    let description: String?
    let addProducts: [AddProducts]?
    let lat, long: Double?
    let startDate, endDate: String?
    let status: Status?
    let createdAt, updatedAt: String?
    let user: UserDetaa?
    let Requests,timeStatus: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, usertype,timeStatus
        case businessLogo = "business_logo"
        case description, addProducts, lat, long, startDate, endDate, status, createdAt, updatedAt, user,place,Requests,image
       
    }
}
// MARK: - Status
struct Status: Codable {
    let id: String?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case status
    }
}
// MARK: - AddProduct
struct AddProducts: Codable {
    let productName: String?
    let price: Int?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case productName, price
        case id = "_id"
    }
}

// MARK: - User
struct UserDetaa: Codable {
    let id, name: String?
    let profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case profilePhoto = "profile_photo"
    }
}

