//
//  HomeFilterVC.swift
//  SecretWorld
//
//  Created by Ideio Soft on 16/12/24.
//

//  HomeFilterVC.swift
//  SecretWorld
//
//  Created by Ideio Soft on 16/12/24.
//

import UIKit
import RangeUISlider
import RangeSeekSlider

class HomeFilterVC: UIViewController {
    @IBOutlet weak var lblTemprary: UILabel!
    @IBOutlet weak var vwTemprary: UIView!
    @IBOutlet weak var vwResult: UIView!
    @IBOutlet weak var tblVwFilter: UITableView!
    @IBOutlet weak var vwApply: UIView!
    @IBOutlet weak var lblResult: UILabel!
    private var selectedIndex: Int?
    private var isDropdownVisible = false
    private var arrGigFilter = [String]()
    private var minPrice:Int = 1
    private var maxPrice:Int = 10000
    private var maxTime:Int = 24
    private var minTime:Int = 1
    private var radius:Int = 50
    private var popularity = 1
    private var endingSoon = 1
    private var rating = 0
    private var minDeal = 1
    private var maxDeal = 100
    private var isSelectGigPrice = false
    private var isSelectGigTime = false
    
    private var isSelectPopularity = false
    private var isSelectEndingSoon = false
    
    private var isSelectDealing = false
    private var isSelectRating = false
    
    var callBack: ((_ radius: Int) -> ())?
    var type:Int = 0
    var lat:Double = 0.0
    var long:Double = 0.0
    var gigType = 0
    var gigCount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
   
        if type == 1{
            
            arrGigFilter.append("Distance")
            arrGigFilter.append("Price")
            arrGigFilter.append("Completion Time")
            self.lblResult.text = "Showing \(gigCount) gig"
        }else if type == 2{
            arrGigFilter.append("Popularity")
            arrGigFilter.append("Ending Soonest")
            arrGigFilter.append("Distance")
            self.lblResult.text = "Showing \(gigCount) popUp"
        }else{
            arrGigFilter.append("Distance")
            arrGigFilter.append("Deals")
            arrGigFilter.append("Rating")
            self.lblResult.text = "Showing \(gigCount) Business"
        }
    }
    
    private func setupTableView() {
        tblVwFilter.delegate = self
        tblVwFilter.dataSource = self
        tblVwFilter.estimatedRowHeight = 50
        tblVwFilter.rowHeight = UITableView.automaticDimension
     
    }
    
    func setGigFilter() {
   
            switch (isSelectGigPrice, isSelectGigTime) {
            case (false, false):
                print("false", "false")
                if Store.GigType == 0 || Store.GigType == 1{
                   
                    let param = ["userId": Store.userId ?? "",
                                 "lat": lat,
                                 "long": long,
                                 "type":type,
                                 "gigType":Store.GigType ?? 0,
                                 "radius": radius] as [String: Any]
                    print("Param----", param)
                    SocketIOManager.sharedInstance.home(dict: param)
                    Store.filterData = ["radius":radius]
                }else{
                    let param = ["userId": Store.userId ?? "",
                                 "lat": lat,
                                 "long": long,
                                 "type":type,
                                 "radius": radius] as [String: Any]
                    print("Param----", param)
                    SocketIOManager.sharedInstance.home(dict: param)
                    Store.filterData = ["radius":radius]
                }
            case (true, false):
                print("true", "false")
                if Store.GigType == 0 || Store.GigType == 1{
                    let param = ["userId": Store.userId ?? "",
                                 "lat": lat,
                                 "long": long,
                                 "type":type,
                                 "gigType":Store.GigType ?? 0,
                                 "radius": radius,
                                 "price_min":minPrice,"price_max":maxPrice] as [String: Any]
                    print("Param----", param)
                    SocketIOManager.sharedInstance.home(dict: param)
                    Store.filterData = ["price_min":minPrice,"price_max":maxPrice,"radius":radius]
                }else{
                    let param = ["userId": Store.userId ?? "",
                                 "lat": lat,
                                 "long": long,
                                 "type":type,
                                 "radius": radius,
                                 "price_min":minPrice,"price_max":maxPrice] as [String: Any]
                    print("Param----", param)
                    SocketIOManager.sharedInstance.home(dict: param)
                    Store.filterData = ["price_min":minPrice,"price_max":maxPrice,"radius":radius]
                }
            case (false, true):
                print("false", "true")
                if Store.GigType == 0 || Store.GigType == 1{
                    
                    let param = ["userId": Store.userId ?? "",
                                 "lat": lat,
                                 "long": long,
                                 "type":type,
                                 "gigType":Store.GigType ?? 0,
                                 "radius": radius,
                                 "minHours":minTime,
                                 "maxHours":maxTime] as [String: Any]
                    print("Param----", param)
                    SocketIOManager.sharedInstance.home(dict: param)
                    Store.filterData = ["minHours":minTime,"maxHours":maxTime,"radius":radius]
                }else{
                    let param = ["userId": Store.userId ?? "",
                                 "lat": lat,
                                 "long": long,
                                 "type":type,
                                 "radius": radius,
                                 "minHours":minTime,
                                 "maxHours":maxTime] as [String: Any]
                    print("Param----", param)
                    SocketIOManager.sharedInstance.home(dict: param)
                    Store.filterData = ["minHours":minTime,"maxHours":maxTime,"radius":radius]
                }
            case (true, true):
                print("true", "true")
                if Store.GigType == 0 || Store.GigType == 1{
                    let param = ["userId": Store.userId ?? "",
                                 "lat": lat,
                                 "long": long,
                                 "type":type,
                                 "gigType":Store.GigType ?? 0,
                                 "radius": radius,
                                 "minHours":minTime,
                                 "maxHours":maxTime,"price_min":minPrice,"price_max":maxPrice] as [String: Any]
                    print("Param----", param)
                    SocketIOManager.sharedInstance.home(dict: param)
                    Store.filterData = ["minHours":minTime,"maxHours":maxTime,"price_min":minPrice,"price_max":maxPrice,"radius":radius]
                }else{
                    let param = ["userId": Store.userId ?? "",
                                 "lat": lat,
                                 "long": long,
                                 "type":type,
                                 "radius": radius,
                                 "minHours":minTime,
                                 "maxHours":maxTime,"price_min":minPrice,"price_max":maxPrice] as [String: Any]
                    print("Param----", param)
                    SocketIOManager.sharedInstance.home(dict: param)
                    Store.filterData = ["minHours":minTime,"maxHours":maxTime,"price_min":minPrice,"price_max":maxPrice,"radius":radius]
                }
            }
    }
    
    func setPopUpFilter() {
   
        switch (isSelectPopularity,isSelectEndingSoon) {
            case (false, false):
                print("false", "false")
              
                let param = ["userId": Store.userId ?? "",
                             "lat": lat,
                             "long": long,
                             "type":type,
                             "radius": radius] as [String: Any]
                print("Param----", param)
            SocketIOManager.sharedInstance.home(dict: param)
            Store.filterDataPopUp = ["radius":radius]
            case (true, false):
                print("true", "false")
            let param = ["userId": Store.userId ?? "",
                         "lat": lat,
                         "long": long,
                         "type":type,
                         "radius": radius,
                         "popularity":popularity] as [String: Any]
            print("Param----", param)
            SocketIOManager.sharedInstance.home(dict: param)
            Store.filterDataPopUp = ["popularity":popularity,"radius":radius]
            case (false, true):
                print("false", "true")
            let param = ["userId": Store.userId ?? "",
                         "lat": lat,
                         "long": long,
                         "type":type,
                         "radius": radius,
                         "endingSoon":endingSoon] as [String: Any]
            print("Param----", param)
            SocketIOManager.sharedInstance.home(dict: param)
            Store.filterDataPopUp = ["endingSoon":endingSoon,"radius":radius]
            case (true, true):
                print("true", "true")
            let param = ["userId": Store.userId ?? "",
                         "lat": lat,
                         "long": long,
                         "type":type,
                         "radius": radius,
                         "popularity":popularity,
                         "endingSoon":endingSoon] as [String: Any]
            print("Param----", param)
            SocketIOManager.sharedInstance.home(dict: param)
            Store.filterDataPopUp = ["popularity":popularity,"endingSoon":endingSoon,"radius":radius]
            }
    }
    func setBusinessFilter(){
        switch (isSelectDealing,isSelectRating) {
            case (false, false):
            print("false", "false")
            let param = ["userId": Store.userId ?? "",
                         "lat": lat,
                         "long": long,
                         "type":type,
                         "radius": radius] as [String: Any]
            print("Param----", param)
            SocketIOManager.sharedInstance.home(dict: param)
            Store.filterDataBusiness = ["radius":radius]
            
            case (true, false):
            print("true", "false")
            let param = ["userId": Store.userId ?? "",
                         "lat": lat,
                         "long": long,
                         "type":type,
                         "radius": radius,
                         "minDeal":minDeal,
                         "maxDeal":maxDeal] as [String: Any]
            print("Param----", param)
            SocketIOManager.sharedInstance.home(dict: param)
            Store.filterDataBusiness = ["minDeal":minDeal,"maxDeal":maxDeal,"radius":radius]
            
            case (false, true):
                print("false", "true")
            let param = ["userId": Store.userId ?? "",
                         "lat": lat,
                         "long": long,
                         "type":type,
                         "radius": radius,
                         "rating":rating] as [String: Any]
            print("Param----", param)
            SocketIOManager.sharedInstance.home(dict: param)
            Store.filterDataBusiness = ["rating":rating,"radius":radius]
            
            case (true, true):
                print("true", "true")
            let param = ["userId": Store.userId ?? "",
                         "lat": lat,
                         "long": long,
                         "type":type,
                         "radius": radius,
                         "minDeal":minDeal,
                         "maxDeal":maxDeal,"rating":rating] as [String: Any]
            print("Param----", param)
            SocketIOManager.sharedInstance.home(dict: param)
            Store.filterDataBusiness = ["minDeal":minDeal,"maxDeal":maxDeal,"rating":rating,"radius":radius]
            
            }
    }
   
    @IBAction func actionReset(_ sender: UIButton) {
        if type == 1{
            isSelectGigTime = false
            isSelectGigPrice = false
            Store.filterData = nil
            Store.isSelectGigFilter = false
        }else if type == 2{
            isSelectPopularity = false
            isSelectEndingSoon = false
            Store.filterDataPopUp = nil
            Store.isSelectPopUpFilter = false
        }else{
            isSelectDealing = false
            isSelectRating = false
            Store.filterDataBusiness = nil
            Store.isSelectBusinessFilter = false
        }
      
        
        tblVwFilter.reloadData()
    }
    @IBAction func actionCross(_ sender: UIButton) {
        dismiss(animated: false)
        callBack?(Store.filterData?["radius"] as? Int ?? 0)
    }
    @IBAction func actionApply(_ sender: UIButton) {
        if type == 1{
            callBack?(radius)
            setGigFilter()
           
            Store.isSelectGigFilter = true
        }else if type == 2{
            callBack?(radius)
            setPopUpFilter()
            Store.isSelectPopUpFilter = true
        }else{
            callBack?(radius)
            setBusinessFilter()
            Store.isSelectBusinessFilter = true
        }
       
    }
}
// MARK: - UITableViewDelegate & UITableViewDataSource
extension HomeFilterVC: UITableViewDelegate, UITableViewDataSource,RangeSeekSliderDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrGigFilter.count
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeFilterTVC", for: indexPath) as? HomeFilterTVC else {
            return UITableViewCell()
        }
        let isCurrentRowSelected = (selectedIndex == indexPath.row && isDropdownVisible)
        cell.lblTitle.text = arrGigFilter[indexPath.row]
        if type == 1{
            if indexPath.row == 0 {
                cell.rangeSlider.minValue = 50
                cell.rangeSlider.maxValue = 1000
                cell.rangeSlider.selectedMinValue = CGFloat(Store.filterData?["radius"] as? Int ?? 50)
                cell.rangeSlider.selectedMaxValue = 1000
                cell.rangeSlider.leftHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.rightHandleImage = UIImage(named: "seeGig")
                cell.rangeSlider.tag = indexPath.row
                cell.sliderDistance.value = 0
                
                // Add target to handle slider value change
                cell.sliderDistance.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
                let isCurrentRowSelected = (selectedIndex == indexPath.row && isDropdownVisible)
                cell.SliderVw.isHidden = !isCurrentRowSelected
                cell.vwDistance.isHidden = true
                cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
                cell.rangeSlider.delegate = self
            } else if indexPath.row == 1 {
                cell.rangeSlider.leftHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.rightHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.minValue = 50
                cell.rangeSlider.maxValue = 10000
                cell.rangeSlider.selectedMinValue = CGFloat(Store.filterData?["minPrice"] as? Int ?? 1)
                cell.rangeSlider.selectedMaxValue = CGFloat(Store.filterData?["maxPrice"] as? Int ?? 10000)
                cell.SliderVw.isHidden = !isCurrentRowSelected
                cell.vwDistance.isHidden = true
                cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
                cell.rangeSlider.tag = indexPath.row
                cell.rangeSlider.delegate = self
            } else {
                cell.rangeSlider.leftHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.rightHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.minValue = 1
                cell.rangeSlider.maxValue = 24
                cell.rangeSlider.selectedMinValue = CGFloat(Store.filterData?["minTime"] as? Int ?? 1)
                cell.rangeSlider.selectedMaxValue = CGFloat(Store.filterData?["maxTime"] as? Int ?? 24)
                cell.SliderVw.isHidden = !isCurrentRowSelected
                cell.vwDistance.isHidden = true
                cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
                cell.rangeSlider.tag = indexPath.row
                cell.rangeSlider.delegate = self
            }

        }else if type == 2{
            if indexPath.row == 0 {
                cell.rangeSlider.minValue = 1
                cell.rangeSlider.maxValue = 5
                cell.rangeSlider.selectedMinValue = CGFloat(Store.filterDataPopUp?["popularity"] as? Int ?? 0)
                cell.rangeSlider.selectedMaxValue = 5
                cell.rangeSlider.enableStep = true
                cell.rangeSlider.step = 1
                cell.rangeSlider.leftHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.rightHandleImage = UIImage(named: "seeGig")
                cell.rangeSlider.tag = indexPath.row
                cell.sliderDistance.value = 0
                cell.rangeSlider.delegate = self
                // Add target to handle slider value change
                cell.sliderDistance.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
                let isCurrentRowSelected = (selectedIndex == indexPath.row && isDropdownVisible)
                cell.SliderVw.isHidden = !isCurrentRowSelected
                cell.vwDistance.isHidden = true
                cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
            } else if indexPath.row == 1 {
                cell.rangeSlider.leftHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.rightHandleImage = UIImage(named: "seeGig")
                cell.rangeSlider.minValue = 1
                cell.rangeSlider.maxValue = 24
                cell.rangeSlider.selectedMinValue = CGFloat(Store.filterDataPopUp?["endingSoon"] as? Int ?? 1)
                cell.rangeSlider.selectedMaxValue = 24
                cell.SliderVw.isHidden = !isCurrentRowSelected
                cell.vwDistance.isHidden = true
                cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
                cell.rangeSlider.tag = indexPath.row
                cell.rangeSlider.delegate = self
            } else {
                cell.rangeSlider.leftHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.rightHandleImage = UIImage(named: "seeGig")
                cell.rangeSlider.minValue = 50
                cell.rangeSlider.maxValue = 1000
                cell.rangeSlider.selectedMinValue =  CGFloat(Store.filterDataPopUp?["radius"] as? Int ?? 50)
                cell.rangeSlider.selectedMaxValue = 1000
                cell.SliderVw.isHidden = !isCurrentRowSelected
                cell.vwDistance.isHidden = true
                cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
                cell.rangeSlider.tag = indexPath.row
                cell.rangeSlider.delegate = self
            }

        }else{
            if indexPath.row == 0 {
                cell.rangeSlider.minValue = 50
                cell.rangeSlider.maxValue = 1000
                cell.rangeSlider.selectedMinValue = CGFloat(Store.filterDataBusiness?["radius"] as? Int ?? 50)
                cell.rangeSlider.selectedMaxValue = 1000
                cell.rangeSlider.leftHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.rightHandleImage = UIImage(named: "seeGig")
                cell.rangeSlider.tag = indexPath.row
                cell.sliderDistance.value = 0
                cell.rangeSlider.delegate = self
                // Add target to handle slider value change
                cell.sliderDistance.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
                let isCurrentRowSelected = (selectedIndex == indexPath.row && isDropdownVisible)
                cell.SliderVw.isHidden = !isCurrentRowSelected
                cell.vwDistance.isHidden = true
                cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
            } else if indexPath.row == 1 {
                cell.rangeSlider.leftHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.rightHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.minValue = 1
                cell.rangeSlider.maxValue = 100
                cell.rangeSlider.selectedMinValue = CGFloat(Store.filterDataBusiness?["minDeal"] as? Int ?? 1)
                cell.rangeSlider.selectedMaxValue = CGFloat(Store.filterDataBusiness?["maxDeal"] as? Int ?? 100)
                cell.SliderVw.isHidden = !isCurrentRowSelected
                cell.vwDistance.isHidden = true
                cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
                cell.rangeSlider.tag = indexPath.row
                cell.rangeSlider.delegate = self
            } else {
                cell.rangeSlider.leftHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.rightHandleImage = UIImage(named: "uncheckreview")
                cell.rangeSlider.minValue = 0
                cell.rangeSlider.maxValue = 5
                cell.rangeSlider.selectedMinValue = CGFloat(Store.filterDataBusiness?["rating"] as? Int ?? 1)
                cell.rangeSlider.selectedMaxValue = 5
                cell.rangeSlider.enableStep = true
                cell.rangeSlider.step = 1
                cell.SliderVw.isHidden = !isCurrentRowSelected
                cell.vwDistance.isHidden = true
                cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
                cell.rangeSlider.tag = indexPath.row
                cell.rangeSlider.delegate = self
            }

        }
        cell.btnDropDown.tag = indexPath.row
        cell.btnDropDown.addTarget(self, action: #selector(handleDropDown(_:)), for: .touchUpInside)
        return cell
    }
    @objc func sliderValueChanged(_ sender: UISlider) {
        Store.filterData = ["distance":Int(sender.value)]
    }
    // MARK: - RangeSeekSliderDelegate
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
       
            if type == 1{
                switch slider.tag {
                case 0:
                    radius = Int(minValue)
                    
                case 1: // Price Slider
                    minPrice = Int(minValue)
                    maxPrice = Int(maxValue)
                    isSelectGigPrice = true
                case 2: // Time Slider
                    minTime = Int(minValue)
                    maxTime = Int(maxValue)
                    isSelectGigTime = true
                default:
                    break
                }
            }else if type == 2{
                switch slider.tag {
                case 0:
                    popularity = Int(minValue)
                    isSelectPopularity = true
                case 1:
                    endingSoon = Int(minValue)
                    isSelectEndingSoon = true
                case 2:
                    radius = Int(minValue)
                 
                default:
                    break
                }
            }else{
                switch slider.tag {
                case 0:
                    radius = Int(minValue)
                case 1: // Price Slider
                    minDeal = Int(minValue)
                    maxDeal = Int(maxValue)
                    isSelectDealing = true
                case 2: // Time Slider
                    rating = Int(minValue)
                    isSelectRating = true
                default:
                    break
                }
            }
       
    }
    @objc private func handleDropDown(_ sender: UIButton) {
        let tappedIndex = sender.tag
        if selectedIndex == tappedIndex {
            isDropdownVisible.toggle()
        } else {
            selectedIndex = tappedIndex
            isDropdownVisible = true
        }
        tblVwFilter.reloadData()
    }
}
