//
//  BusinessTypeVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 27/12/23.
//

import UIKit

class BusinessTypeVC: UIViewController {
    @IBOutlet var viewBackground: UIView!
    @IBOutlet var btnPermanant: UIButton!
    @IBOutlet var btnTemprary: UIButton!
    
    var callBack:((_ businessType:String?)->())?
    var type:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        viewBackground.layer.cornerRadius = 35
        viewBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
       
        
        if type == btnPermanant.titleLabel?.text{
            btnPermanant.isSelected = true
        }else{
            btnTemprary.isSelected = true
        }
        
    }
   
    @IBAction func actionDimiss(_ sender: UIButton) {
        
        self.dismiss(animated: true)
        self.callBack?(type)
    }
    
    @IBAction func actionTemprary(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            btnPermanant.isSelected = false
            self.dismiss(animated: true)
            self.callBack?(sender.title(for: .normal))
        }
    }
    @IBAction func actionPermanant(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            btnTemprary.isSelected = false
            self.dismiss(animated: true)
            self.callBack?(sender.title(for: .normal))
        }
    }
}
