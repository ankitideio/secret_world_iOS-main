//
//  TimerVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 30/01/25.
//

import UIKit

class TimerVC: UIViewController {

    @IBOutlet var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
    }
    private func setupDatePicker() {
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

    }
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let selectedTime = formatter.string(from: sender.date)
        print("Selected Time: \(selectedTime)")
    }

}
