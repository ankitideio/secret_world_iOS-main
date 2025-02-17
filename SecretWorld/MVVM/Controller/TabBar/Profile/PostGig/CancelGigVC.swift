//
//  CancelGigVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 04/01/24.
//

import UIKit

class CancelGigVC: UIViewController {

    
    @IBOutlet var heightViewBAck: NSLayoutConstraint!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgVw: UIImageView!
    
    var isSelect = 0
    var viewModelService = AddServiceVM()
    var viewModelItinerary = ItineraryVM()
    var viewModelGig = AddGigVM()
    var gigId = ""
    var callBack:((_ message:String?)->())?
    var viewModelPopup = PopUpVM()
    var popupId = ""
    var reviewId = ""
    var bankId = ""
    var viewModel = PaymentVM()
    var date = ""
    var itineraryId = ""
    var viewModelDeal = DealsVM()
    var dealId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        uiSet()
     }
     func uiSet(){
         switch isSelect{
         case 0:
             lblTitle.text = "Cancel the Task"
             print("gigid",gigId)
             lblSubTitle.text = "Are you sure you want to cancel this task? This action cannot be undone."
             imgVw.image = UIImage(named: "cancelgig")
             heightViewBAck.constant = 264
         case 1:
             lblTitle.text = "Delete the Service"
             lblSubTitle.text = "Are you sure you want to Delete this service?"
             imgVw.image = UIImage(named: "deleteservice")
             heightViewBAck.constant = 264
        
         case 2:
             lblTitle.text = "Delete the popup"
             lblSubTitle.text = "Are you sure you want to Delete this popup?"
             imgVw.image = UIImage(named: "deleteservice")
             heightViewBAck.constant = 264
         case 3:
             lblTitle.text = "Are you sure?"
             lblSubTitle.text = "you want to delete this bank detail."
             imgVw.image = UIImage(named: "deleteservice")
             heightViewBAck.constant = 230
         case 4:
             lblTitle.text = "Delete the Review"
             lblSubTitle.text = "you want to delete this review."
             imgVw.image = UIImage(named: "deleteservice")
             heightViewBAck.constant = 230
         case 5:
             lblTitle.text = "Delete the Itinerary"
             lblSubTitle.text = "Are you sure you want to delete this itinerary? This action cannot be undone."
             imgVw.image = UIImage(named: "deleteservice")
             heightViewBAck.constant = 264
         case 6:
             lblTitle.text = "Delete the Deal"
             lblSubTitle.text = "Are you sure you want to delete this deal? This action cannot be undone."
             imgVw.image = UIImage(named: "deleteservice")
             heightViewBAck.constant = 264
         default:
             break
         }
     }
    @IBAction func actionYes(_ sender: UIButton) {
        switch isSelect{
        case 0:
            viewModelGig.CancelGigApi(id: gigId) { message in
                self.dismiss(animated: true)
                self.callBack?(message)
            }
        case 1:
            viewModelService.DeleteServiceApi(id: Store.ServiceId ?? "") {
                NotificationCenter.default.post(name: Notification.Name("AddService"), object: nil)
                self.dismiss(animated: true)
                SceneDelegate().tabBarMenuVCRoot()
               
            }
        case 2:
            viewModelPopup.deletePopuptApi(id: popupId) { message in
                self.dismiss(animated: true)
                self.callBack?(message)
            }
        case 3:
            viewModel.DeleteBankApi(bankAccountId: bankId) { message in
                self.dismiss(animated: true)
                self.callBack?(message)
            }
        case 4:
        
            viewModelPopup.deletePopupReview(reviewId: reviewId) {  message in
                self.dismiss(animated: true)
                self.callBack?(message)
            }
            
        case 5:
            viewModelItinerary.deleteItinerary(id: itineraryId, date: date) { message in
                self.dismiss(animated: true)
                self.callBack?(message)
            }
        case 6:
            viewModelDeal.deleteDealsApi(dealId: dealId) { message in
                self.dismiss(animated: true)
                self.callBack?(message)
            }
            
        default:
            break
        }
        
    }
    
    @IBAction func actionNo(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
