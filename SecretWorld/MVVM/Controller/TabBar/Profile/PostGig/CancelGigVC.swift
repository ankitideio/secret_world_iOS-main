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
    var viewModelGig = AddGigVM()
    var gigId = ""
    var callBack:((_ message:String?)->())?
    var viewModelPopup = PopUpVM()
    var popupId = ""
    var bankId = ""
    var viewModel = PaymentVM()
    override func viewDidLoad() {
        super.viewDidLoad()
   
        uiSet()
     }
     func uiSet(){
         switch isSelect{
         case 0:
             lblTitle.text = "Cancel the Gig"
             print("gigid",gigId)
             lblSubTitle.text = "Are you sure you want to cancel this gig? This action cannot be undone."
             imgVw.image = UIImage(named: "deleteservice")
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
        default:
            break
        }
        
    }
    
    @IBAction func actionNo(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
