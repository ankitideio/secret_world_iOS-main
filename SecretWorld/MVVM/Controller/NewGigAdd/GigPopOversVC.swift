//
//  GigPopOversVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 20/12/24.
//

import UIKit

class GigPopOversVC: UIViewController {

    @IBOutlet var tblVwList: UITableView!
    var arrTitle = [String]()
    var callBack:((_ type:String,_ title:String,_ id:String)->())?
    var selectedIndex = 0
    var type:String?
    var viewModelAuth = AuthVM()
    var arrGetCategories = [Skills]()
    var arrGetSkills = [Skills]()
    var offset = 1
    var limit = 20
    var isWorldwide = false
    var locationType = ""
    var arrAppliedGig = [GetAppliedData]()
    var arrProduct = [ServiceDetail]()
    var participantsList:[Participantzz]?
    var businessGigDetail:GetGigDetailData?
    var callBackBusiness:((_ name:String,_ index:Int)->())?
    var callBackItinerary:((_ type:String,_ title:String,_ id:String,_ price:Int)->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
    }
    
    func uiSet(){
        
               if let popOverType = type {
                   switch popOverType {
                   case "category":
                       tblVwList.reloadData()
                   case "experience":
                       arrTitle.append("Below 1 Year")
                       arrTitle.append("1 Year")
                       arrTitle.append("1-2 Year")
                       arrTitle.append("2-3 Year")
                   case "payment":
                       arrTitle.append("Fixed")
                       arrTitle.append("Hourly")
                       
                   case "tools":
                       arrTitle.append("Add your own")
                       arrTitle.append("Photoshop")
                       arrTitle.append("Figma")
                       arrTitle.append("Microsoft")
                       arrTitle.append("Excel")
                       
                   case "skills":
                       tblVwList.reloadData()
                   case "paymentMethod":
                       if locationType == "worldwide"{
                           arrTitle.append("Online")
                       }else{
                           arrTitle.append("Cash")
                           arrTitle.append("Online")
                       }
                   case "calender":
                       tblVwList.reloadData()
                   case "Product":
                       tblVwList.reloadData()
                   case "graphType":
                       arrTitle.append("Weekly")
                       arrTitle.append("Monthly")
                       arrTitle.append("Yearly")
                   case "CreateBusiness":
                       arrTitle.append("Restaurants")
                       arrTitle.append("Retail")
                       arrTitle.append("Beauty & wellness")
                       arrTitle.append("Events")
                   case "review":
                       participantsList = businessGigDetail?.participantsList ?? []
                       tblVwList.reloadData()
                   default:
                       break
                   }
               }
        tblVwList.reloadData()
    }

}
//MARK: - UITableViewDelegate
extension GigPopOversVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == "category"{
            if arrGetCategories.count > 0{
                return arrGetCategories.count
            }else{
                return 0
            }
        }else if type == "skills"{
            if arrGetSkills.count > 0{
                return arrGetSkills.count
            }else{
                return 0
            }
        }else if type == "calender"{
            if arrAppliedGig.count > 0{
                return arrAppliedGig.count
            }else{
                return 0
            }
        }else if type == "Product"{
            if arrProduct.count > 0{
                return arrProduct.count
            }else{
                return 0
            }
        }else if type == "review"{
            if participantsList?.count ?? 0 > 0{
                return participantsList?.count ?? 0
            }else{
                return 0
            }
        }else{
            if arrTitle.count > 0{
                return arrTitle.count
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GigPopOverTVC", for: indexPath) as! GigPopOverTVC
           
        if type == "category"{
            cell.lblTitle.text = arrGetCategories[indexPath.row].name
        }else if type == "skills"{
            cell.lblTitle.text = arrGetSkills[indexPath.row].name
        }else if type == "calender"{
            cell.lblTitle.text = arrAppliedGig[indexPath.row].gig?.title ?? ""
        }else if type == "review"{
            cell.lblTitle.text = participantsList?[indexPath.row].name ?? ""
        }else if type == "Product"{
            cell.lblTitle.text = arrProduct[indexPath.row].serviceName ?? ""
            }else {
                cell.lblTitle.text = arrTitle[indexPath.row]
            }
            if type == "category"{
                cell.btnAdd.isHidden = true
            }else {
                cell.btnAdd.isHidden = true
            }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: false)
        if type == "category"{
            callBack?(type ?? "", arrGetCategories[indexPath.row].name, arrGetCategories[indexPath.row].id)
        }else if type == "skills"{
            callBack?(type ?? "", arrGetSkills[indexPath.row].name, arrGetSkills[indexPath.row].id)
        }else if type == "calender"{
            callBackItinerary?(type ?? "", arrAppliedGig[indexPath.row].gig?.title ?? "", arrAppliedGig[indexPath.row].gig?.id ?? "", arrAppliedGig[indexPath.row].gig?.price ?? 0)
        }else if type == "Product"{
            callBack?(type ?? "", arrProduct[indexPath.row].serviceName ?? "", arrProduct[indexPath.row]._id ?? "")
        }else if type == "review"{
            callBack?(type ?? "", participantsList?[indexPath.row].name ?? "", participantsList?[indexPath.row].id ?? "")
        }else{
            callBack?(type ?? "", arrTitle[indexPath.row], "")
            callBackBusiness?(arrTitle[indexPath.row],indexPath.row+1)
        }
      }
}
