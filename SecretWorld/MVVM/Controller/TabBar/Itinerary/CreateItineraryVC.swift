//
//  CreateItineraryVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 02/01/25.
//

import UIKit
import IQKeyboardManagerSwift

class CreateItineraryVC: UIViewController {
//MARK: - IBOutlet
    @IBOutlet var txtFldDate: UITextField!
    @IBOutlet var txtfldTime: UITextField!
    @IBOutlet var txtVwDescription: IQTextView!
    @IBOutlet var txtFldTask: UITextField!
    @IBOutlet var txtFldTItle: UITextField!
    
    //MARK: - variables
    var callBack: ((String, String, String) -> ())?
    var isComing = false
    var getTitle = ""
    //MARK: - viewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
    }
    func uiSet(){
        txtFldDate.tag = 1
        txtfldTime.tag = 2
        setupDatePickers()
        if isComing{
            GetEventdata()
        }
    }
    func GetEventdata(){
        
    }
    //MARK: - IBAction
    @IBAction func actionsave(_ sender: UIButton) {
        guard let title = txtFldTItle.text,
              let date = txtFldDate.text,
              let time = txtfldTime.text else {
            return
        }
        callBack?(title, date, time)
        self.dismiss(animated: true)
    }
    
    @IBAction func actionSelectTask(_ sender: Any) {
    }
    @IBAction func actionDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
// MARK: - Handle TextFields DatePicker
extension CreateItineraryVC {
    private func setupDatePickers() {
        setupDatePicker(for: txtFldDate, mode: .date, selector: #selector(dateDonePressed))
        setupDatePicker(for: txtfldTime, mode: .time, selector: #selector(timeDonePressed))
    }

    func setupDatePicker(for textField: UITextField, mode: UIDatePicker.Mode, selector: Selector) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = mode
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        textField.inputView = datePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: selector)
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        textField.inputAccessoryView = toolbar

        // Associate the date picker with the text field
        if textField == txtFldDate {
            datePicker.tag = 1
        } else if textField == txtfldTime {
            datePicker.tag = 2
        }
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }

    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        if sender.tag == 1 { // Date Picker for txtFldDate
            dateFormatter.dateFormat = "dd-MM-yyyy"
            txtFldDate.text = dateFormatter.string(from: sender.date)
        } else if sender.tag == 2 { // Time Picker for txtfldTime
            dateFormatter.dateFormat = "h:mm a"
            txtfldTime.text = dateFormatter.string(from: sender.date)
        }
    }

    @objc func dateDonePressed() {
        if let datePicker = txtFldDate.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            txtFldDate.text = dateFormatter.string(from: datePicker.date)
        }
        txtFldDate.resignFirstResponder()
    }

    @objc func timeDonePressed() {
        if let datePicker = txtfldTime.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            txtfldTime.text = dateFormatter.string(from: datePicker.date)
        }
        txtfldTime.resignFirstResponder()
    }
}
