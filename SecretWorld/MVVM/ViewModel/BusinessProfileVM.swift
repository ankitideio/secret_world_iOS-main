//
//  BusinessProfileVM.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 12/02/24.
//

import Foundation
import UIKit
class BusinessProfileVM{
    var serviceJson = String()
    var openingHourJson = String()
    
    func GetBusinessUserProfile(id:String,loader:Bool,onSccess:@escaping((GetBusinessUserDetail?)->())){
        if id == ""{
            WebService.service(API.getUserProfileView,urlAppendId: "null",service: .get,showHud: loader,is_raw_form: true) {
                (model:GetBusinessUserModel,jsonData,jsonSer) in
                
                onSccess(model.data)
                
            }
        }else{
            WebService.service(API.getUserProfileView,urlAppendId: id,service: .get,showHud: true,is_raw_form: true) { (model:GetBusinessUserModel,jsonData,jsonSer) in
                
                onSccess(model.data)
                
            }
        }
       
        
    }
    func updateBusinessProfile(name:String,dob:String,about:String,gender:String,profilePhoto:UIImageView,coverPhoto:UIImageView,services:[[String:String]],openingHour:[[String:String]],onSuccess:@escaping((_ message:String?)->())){
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.fullDate.rawValue
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: Date())
        
        do {
            
            let outputArray = services.map { dictionary in
                return dictionary as [String: String]
            }
            
            let openingHourArray = openingHour.map { dictionary in
                return dictionary as [String:String]
            }
            if let jsonData = try? JSONSerialization.data(withJSONObject: outputArray, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                
                serviceJson = jsonString
            } else {
                print("Error converting array to JSON.")
            }
            
            if let jsonHourData = try? JSONSerialization.data(withJSONObject: openingHourArray, options: .prettyPrinted),
               let jsonString = String(data: jsonHourData, encoding: .utf8) {
                
                openingHourJson = jsonString
            } else {
                print("Error converting array to JSON.")
            }
            
            let imageInfoProfile : ImageStructInfo
            
            imageInfoProfile = ImageStructInfo.init(fileName: "Img\(date).jpeg", type: "jpeg", data: profilePhoto.image?.toData() ?? Data(), key: "profile_photo")
            
            let imageInfoCover : ImageStructInfo
            
            imageInfoCover = ImageStructInfo.init(fileName: "Img\(date).jpeg", type: "jpeg", data: coverPhoto.image?.toData() ?? Data(), key: "cover_photo")
            
            
            
            let param:parameters = ["name":name,"about":about,"dob":dob,"gender":gender,"profile_photo":imageInfoProfile,"cover_photo":imageInfoCover,"services":serviceJson,"openinghours":openingHourJson]
            print(param)
            WebService.service(API.updateBusinessProfile,param: param,service: .put,is_raw_form: false) { (model:CommonModel,jsonData,jsonSer) in
                DispatchQueue.main.async {
                    WebService.hideLoader()
                    }
                onSuccess(model.message)
            }
        } catch {
            print("Error converting dictionary to JSON: \(error)")
        }
        
    }
}
