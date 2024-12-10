//
//  SelectServiceTypeVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 02/01/24.
//

import UIKit
import SwiftMessages

class SelectServiceTypeVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var viewAddgig: UIView!
    @IBOutlet var viewAddPopup: UIView!
    @IBOutlet var btnAddpopup: UIButton!
    @IBOutlet var viewBack: UIView!
    @IBOutlet var btnAddgig: UIButton!
    @IBOutlet var imgVwGig: UIImageView!
    @IBOutlet var imgVwPopup: UIImageView!

    //MARK: - VARIABLES
    var callBack: ((_ isComing:Bool)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
    }
    //MARK: - FUNCTIONS
    func uiSet(){
        if Store.role == "user"{
            viewAddPopup.isHidden = false
            btnAddpopup.isSelected = true
        }else{
            viewAddPopup.isHidden = true
        }
        viewBack.layer.cornerRadius = 20
        viewBack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imgVwGig.image = UIImage(named: "unSelect")
        imgVwPopup.image = UIImage(named: "selectedGender")
        setupOverlayView()
    }
    func setupOverlayView() {
        viewBack = UIView(frame: self.view.bounds)
        viewBack.backgroundColor = UIColor.black.withAlphaComponent(0.5)
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        viewBack.addGestureRecognizer(tapGesture)
          self.view.insertSubview(viewBack, at: 0)
      }
    @objc func overlayTapped() {
          self.dismiss(animated: true)
      }
    //MARK: - BUTTON ACTIONS
    @IBAction func actionDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func actionAddService(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if btnAddpopup.isSelected == true{
            btnAddgig.isSelected = false
            imgVwGig.image = UIImage(named: "unSelect")
            imgVwPopup.image = UIImage(named: "selectedGender")
        }else{
            imgVwPopup.image = UIImage(named: "unSelect")
        }
    }
    @IBAction func actionAddGig(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if btnAddgig.isSelected == true{
            btnAddpopup.isSelected = false
            imgVwGig.image = UIImage(named: "selectedGender")
            imgVwPopup.image = UIImage(named: "unSelect")
        }else{
            imgVwGig.image = UIImage(named: "unSelect")
        }
    }
    
    @IBAction func actionAdd(_ sender: UIButton) {
        Store.AddGigImage = nil
        Store.AddGigDetail = nil
        if btnAddpopup.isSelected || btnAddgig.isSelected {
            self.dismiss(animated: true)
            callBack?(btnAddpopup.isSelected)
               }else{
                   showSwiftyAlert("", "Select type", false)
               }
    }
    
}
