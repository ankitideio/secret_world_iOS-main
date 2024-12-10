//
//  DatePickerVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 21/12/23.
//

import UIKit

class DatePickerVC: UIViewController {
    //MARK: - Outlets
  
    @IBOutlet var lblScreenTitle: UILabel!
    @IBOutlet var viewBackground: UIView!
    @IBOutlet var datePicker: UIDatePicker!
    
    var callBack:((_ datee:String?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
    }
    func uiSet(){
        if Store.role == "b_user"{
            lblScreenTitle.text =  "Since from"
        }else{
            lblScreenTitle.text =  "Date of birth"
        }
        viewBackground.layer.cornerRadius = 35
        viewBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        datePicker.maximumDate = Date()
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = 1960
        dateComponents.month = 1
        dateComponents.day = 1
        let minimumDate = calendar.date(from: dateComponents)
        datePicker.minimumDate = minimumDate
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "en_US_POSIX")
        datePicker.date = Date()

        let initialDate = formatDate(date: datePicker.date)
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
    
    //MARK: - Button Actions
    @IBAction func actionDatePicker(_ sender: UIDatePicker) {
    }
    @IBAction func actionDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func actionContinue(_ sender: UIButton) {
        
        let selectedDate = formatDate(date: datePicker.date)
        print("Selected Date: \(selectedDate)")
        self.dismiss(animated: true)
        self.callBack?(selectedDate)
        
    }
     func formatDate(date: Date) -> String {
         
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"
           return dateFormatter.string(from: date)
         
       }
}
