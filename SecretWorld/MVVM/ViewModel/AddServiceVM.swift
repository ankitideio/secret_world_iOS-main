//
//  AddServiceVM.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 05/02/24.
//

import Foundation
import UIKit
class AddServiceVM{
    func GetServiceDetailUserSideApi(service_id:String,onSccess:@escaping((GetServiceDataaa?)->())){
        let param: parameters = ["service_id": service_id]
        print(param)
        WebService.service(API.getServiceDetailUserSide,param: param,service: .get,is_raw_form: true) { (model:GetServiceDetailUserModel,jsonData,jsonSer) in
            onSccess(model.data)
        }
        
    }
    func DeleteServiceApi(id:String,onSccess:@escaping(()->())){
        
        WebService.service(API.deleteService,urlAppendId: id,service: .delete,showHud: false,is_raw_form: true) { (model:CommonModel,jsonData,jsonSer) in
                onSccess()
        }
        
    }
    func getBusinessServiceDetailApi(service_id:String,onSccess:@escaping((GetServiceDetailDataa?)->())){
        let param: parameters = ["service_id": service_id]
        WebService.service(API.getServiceDetail,param: param,service: .get,is_raw_form: true) { (model:GetBServiceDetailModel,jsonData,jsonSer) in
            Store.ServiceDetailData = model.data
            NotificationCenter.default.post(name: Notification.Name("GetStoreServiceData"), object: nil)

            onSccess(model.data)
        }
        
    }
    
    func getSelectedeCtegoriesApi(onSccess:@escaping((GetCategoryData?)->())){
        
        WebService.service(API.getSelectedCategory,service: .get,showHud: false,is_raw_form: true) { (model:GetSelectedCategoryModel,jsonData,jsonSer) in
            
            onSccess(model.data)
        }
        
    }
    func getServiceCtegoriesApi(offset:Int,
                                limit:Int,
                                search:String,
                                onSccess:@escaping((GetCategoriesData?)->())){
        
        let param: parameters = ["offset": "",
                                 "limit": "",
                                 "search": search]
        
        WebService.service(API.getServiceCategories,param: param,service: .get,showHud: false,is_raw_form: true) { (model:GetServiceCategoryModel,jsonData,jsonSer) in
            
            onSccess(model.data)
        }
        
    }
    func getSubCtegoriesApi(service_id:String,
                            offset:Int,
                            limit:Int,
                            search:String,
                            onSccess:@escaping((GetSubCategoryData?)->())){
        
        let param: parameters = ["service_id":service_id,
                                 "offset": offset,
                                 "limit": limit,
                                 "search": search,]
        
        WebService.service(API.getSubcategory,param: param,service: .get,showHud: false,is_raw_form: true) { (model:GetSubCategoryModel,jsonData,jsonSer) in
            
            onSccess(model.data)
        }
        
    }
    
    func AddServiceApi(serviceName: String,
                       price: String,
                       description: String,
                       serviceImage: [Any],
                       catSubcatArr: [[String: Any]],
                       onSuccess: @escaping((GetUserData?,_ message:String?) -> ())) {
        
        var subCategoryIdArray: [String] = []
        
        for subcat in catSubcatArr {
            guard let categoryId = subcat["category_id"] as? String,
                  let subcategories = subcat["subcategory"] as? [[String: String]] else {
                continue
            }
            for subcategory in subcategories {
                if let subCategoryId = subcategory["subcategory_id"] {
                    subCategoryIdArray.append(subCategoryId)
                }
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.fullDate.rawValue
        let date = formatter.string(from: Date())
     
        var imageStructArr = [ImageStructInfo]()
        for (index, mediaItem) in serviceImage.enumerated() {
            if let image = mediaItem as? UIImage {
                // Handle UIImage (Image)
                let imgStruct = ImageStructInfo(
                    fileName: "\(index).png",
                    type: "image/png",
                    data: image.toData() ?? Data() ,
                    key: "media"
                )
                imageStructArr.append(imgStruct)
                
            }
        }

        do {

            let outputArray = catSubcatArr.map { dictionary in
                return dictionary as [String: Any]
            }

            if let jsonData = try? JSONSerialization.data(withJSONObject: outputArray, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("data===",jsonString)
                let json: [String: Any] = [
                    "serviceName": serviceName,
                    "price": price,
                    "description": description,
                    "serviceImage": imageStructArr,
                    "catSubcatArr": jsonString
                ]
                print(json)
                WebService.service(API.addService, param: json, service: .post, is_raw_form: false) { (model: CreateAccountModel, jsonData, jsonSer) in
                    onSuccess(model.data,model.message)
                }
//                serviceJson = jsonString
            } else {
                print("Error converting array to JSON.")
            }
          
         
        } catch {
            print("Error converting dictionary to JSON: \(error)")
        }
        
    }
    
    func getAllService(loader:Bool,offSet:Int,limit:Int,onSuccess:@escaping((GetBusinessServiceData?)->())){
      
        let param:parameters = ["offset":offSet,"limit":limit]
        WebService.service(API.getAllBusinessService,param: param,service: .get, showHud: loader,is_raw_form: true) { (model:GetBusinessServiceModel,jsonData,jsonSer)in
           
            onSuccess(model.data)
        }
    }
    func EdiServiceApi(service_id: String,
                       serviceName: String,
                       price: String,
                       description: String,
                       serviceImage: [Any],
                       deletedserviceImages: [Any],
                       onSuccess: @escaping((_ message:String?) -> ())) {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.fullDate.rawValue
        let date = formatter.string(from: Date())
        
        var imageStructArr = [ImageStructInfo]()
        for (index, mediaItem) in serviceImage.enumerated() {
            if let image = mediaItem as? UIImage {
                let imgStruct = ImageStructInfo(
                    fileName: "\(index).png",
                    type: "image/png",
                    data: image.toData() ?? Data() ,
                    key: "serviceImage"
                )
                imageStructArr.append(imgStruct)
                
            }
        }
        
        do {
            
                let param: [String: Any] = ["service_id":service_id,
                                           "serviceName": serviceName,
                                           "price": price,
                                           "description": description,
                                           "serviceImage": imageStructArr,
                                           "deletedserviceImages": deletedserviceImages
                ]
          print(param)
                WebService.service(API.UpdateService, param: param, service: .put, is_raw_form: false) { (model: CommonModel, jsonData, jsonSer) in
                    onSuccess(model.message)
                }
            }
        }
    
    
}
