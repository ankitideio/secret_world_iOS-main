//
//  GigTypeVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 28/10/24.
//

import UIKit

class GigTypeVC: UIViewController {
    //MARK: - IBOutlet
    @IBOutlet var lblGigtypeAndLocation: UILabel!
    @IBOutlet var heightStackVwCleatApply: NSLayoutConstraint!
    @IBOutlet var btnApply: UIButton!
    @IBOutlet var btnClear: UIButton!
    @IBOutlet var viewBackground: UIView!
    @IBOutlet var lblWorldwide: UILabel!
    @IBOutlet var imgVwWorldwide: UIImageView!
    @IBOutlet var viewWorldwide: UIView!
    @IBOutlet var lblInmylocation: UILabel!
    @IBOutlet var imgVwInmylocation: UIImageView!
    @IBOutlet var viewInmylocation: UIView!
    //MARK: - variables
    var callBack:((_ gigtype:Int)->())?
    var gigType = 2
    var isComing = false
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
    }
    
    // MARK: - UI Setup
     func uiSet() {
         viewBackground.layer.cornerRadius = 35
         viewBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
         addTapGestures()
         updateUIBasedOnGigType(type: gigType)
        if isComing{
            lblGigtypeAndLocation.text = "Gig type"
            heightStackVwCleatApply.constant = 0
            btnApply.isHidden = true
            btnClear.isHidden = true
            
        }else{
            lblGigtypeAndLocation.text = "Gig location"
            heightStackVwCleatApply.constant = 50
            btnApply.isHidden = false
            btnClear.isHidden = false
        }
         setupOverlayView()
        
    }
    func setupOverlayView() {
        viewBackground = UIView(frame: self.view.bounds)
        viewBackground.backgroundColor = UIColor.black.withAlphaComponent(0.5)
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        viewBackground.addGestureRecognizer(tapGesture)
          self.view.insertSubview(viewBackground, at: 0)
      }
    @objc func overlayTapped() {
          self.dismiss(animated: true)
      }

    func addTapGestures() {
        let tapInMyLocation = UITapGestureRecognizer(target: self, action: #selector(handleTapInMyLocation))
        viewInmylocation.addGestureRecognizer(tapInMyLocation)
        viewInmylocation.isUserInteractionEnabled = true

        let tapWorldwide = UITapGestureRecognizer(target: self, action: #selector(handleTapWorldwide))
        viewWorldwide.addGestureRecognizer(tapWorldwide)
        viewWorldwide.isUserInteractionEnabled = true
    }
    
    // MARK: - Gesture Handlers
    @objc private func handleTapWorldwide() {
        //gigType = "worldwide".
        gigType = 0
        updateUIBasedOnGigType(type: gigType)
        if isComing{
            dismiss(animated: true)
            self.callBack?(self.gigType)
        }
    }
    
    @objc private func handleTapInMyLocation() {
       // gigType = "inMyLocation"
        gigType = 1
        updateUIBasedOnGigType(type: gigType)
        if isComing{
        dismiss(animated: true)
        self.callBack?(self.gigType)
        }
    }
    

    // MARK: - Actions
    @IBAction func actionClear(_ sender: UIButton) {
        gigType = 2
        updateUIBasedOnGigType(type: gigType)
        dismiss(animated: true)
        self.callBack?(gigType)
            

    }
    // MARK: - Update UI
    func updateUIBasedOnGigType(type:Int) {
        
        //gigType = "worldwide" gigType = "inMyLocation"
        if gigType == 0{
            imgVwWorldwide.image = UIImage(named: "world")
            imgVwInmylocation.image = UIImage(named: "inmyGray")
            viewWorldwide.borderWid = 1
            viewWorldwide.borderCol = UIColor(hex: "#3E9C35")
            viewInmylocation.borderWid = 1
            viewInmylocation.borderCol = UIColor(hex: "#DDDDDD")
            viewInmylocation.backgroundColor = .clear
            viewWorldwide.backgroundColor = UIColor(hex: "#3E9C35").withAlphaComponent(0.05)
        } else if gigType == 1{
            imgVwWorldwide.image = UIImage(named: "worldgray")
            imgVwInmylocation.image = UIImage(named: "inmy")
            viewInmylocation.borderWid = 1
            viewInmylocation.borderCol = UIColor(hex: "#3E9C35")
            viewWorldwide.borderWid = 1
            viewWorldwide.borderCol = UIColor(hex: "#DDDDDD")
            viewWorldwide.backgroundColor = .clear
            viewInmylocation.backgroundColor = UIColor(hex: "#3E9C35").withAlphaComponent(0.05)
        } else {
            // Clear state for when no selection is made
            imgVwWorldwide.image = UIImage(named: "worldgray")
            imgVwInmylocation.image = UIImage(named: "inmyGray")
            viewInmylocation.borderWid = 1
            viewInmylocation.borderCol = UIColor(hex: "#DDDDDD")
            viewWorldwide.borderWid = 1
            viewWorldwide.borderCol = UIColor(hex: "#DDDDDD")
            viewWorldwide.backgroundColor = .clear
            viewInmylocation.backgroundColor = .clear
        }
    }

    @IBAction func actionDismiss(_ sender: UIButton) {
        dismiss(animated: true)

    }
    
    @IBAction func actionApply(_ sender: UIButton) {
        if isComing == false{
            dismiss(animated: true)
            self.callBack?(gigType)
        }
    }
    

}
