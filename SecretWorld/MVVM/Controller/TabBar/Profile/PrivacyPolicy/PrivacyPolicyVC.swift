//
//  PrivacyPolicyVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 26/12/23.
//

import UIKit

class PrivacyPolicyVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var txtVwPolicy: UITextView!
    
    //MARK: - VARIABLES
    var isComing = false
    var viewModel = UserProfileVM()
    var content = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)

        
    }
    @objc func handleSwipe() {
                navigationController?.popViewController(animated: true)
            }
    override func viewWillAppear(_ animated: Bool) {
        uiSet()
    }
    
    func uiSet(){
        if isComing == true {
                lblTitle.text = "Privacy Policy"
            viewModel.getUserPolicyTermApi(type: "policy") { data in
                if let policyContent = data?.data?.content {
                    let strippedPolicyContent = policyContent.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                    self.txtVwPolicy.text = strippedPolicyContent
                }
            }
            txtVwPolicy.text = content
            } else {
                lblTitle.text = "About us"
                viewModel.getUserPolicyTermApi(type: "about") { data in
                    if let aboutContent = data?.data?.content {
                        let strippedAboutContent = aboutContent.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                        self.txtVwPolicy.text = strippedAboutContent
                    }
                }
                txtVwPolicy.text = content
            }
    }
   
    //MARK: - BUTTON ACTIONS
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
