//
//  SubCategoryModel.swift
//  SecretWorld
//
//  Created by Ideio Soft on 30/01/25.
//

import Foundation

// MARK: - SubCategoryModel
struct SubCategoryModel: Codable {
    let status, message: String?
    let statusCode: Int?
    let data: SubCategoryData?
}

// MARK: - SubCategoryModel
struct SubCategoryData: Codable {
    let subcategorylist: [Subcategory]
}

// MARK: - Subcategorylist
struct Subcategory: Codable {
    let id, name: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}
