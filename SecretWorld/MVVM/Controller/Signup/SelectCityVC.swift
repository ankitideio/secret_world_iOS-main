//
//  SelectCityVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 22/12/23.
//

import UIKit
import GooglePlaces
class SelectCityVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var txtFldCity: UITextField!
    @IBOutlet var vwShadow: UIView!
    
    //MARK: - VARIBALES
    var cityName:String?
    var shortCityName:String?
    var callBack:((_ cityName:String?,_ lat:Double?,_ long:Double?)->())?
    var latitude = Double()
    var longitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        txtFldCity.text = cityName
        print("shortCityName:--\(shortCityName ?? "")")
        vwShadow.layer.cornerRadius = 25
        vwShadow.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        setupOverlayView()
    }
    func setupOverlayView() {
        vwShadow = UIView(frame: self.view.bounds)
        vwShadow.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        vwShadow.addGestureRecognizer(tapGesture)
        self.view.insertSubview(vwShadow, at: 0)
    }
    @objc func overlayTapped() {
        self.dismiss(animated: true)
    }
    
    //MARK: - BUTTON ACTIONso
    @IBAction func actionSave(_ sender: UIButton) {
        if txtFldCity.text  == ""{
            showSwiftyAlert("", "Select city", false)
        }else{
            self.dismiss(animated: true)
            callBack?(txtFldCity.text ?? "",latitude,longitude)
        }
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    
}

//MARK: - GMSAutocompleteViewControllerDelegate
extension SelectCityVC: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        if place.coordinate.latitude.description.count != 0 {
            self.latitude = place.coordinate.latitude
        }
        if place.coordinate.longitude.description.count != 0 {
            self.longitude = place.coordinate.longitude
        }
        txtFldCity.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate

extension SelectCityVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtFldCity {
            let acController = GMSAutocompleteViewController()
            acController.delegate = self
            
            let filter = GMSAutocompleteFilter()
            filter.countries = [shortCityName ?? ""]
            acController.autocompleteFilter = filter
            
            present(acController, animated: true, completion: nil)
        }
    }
}
