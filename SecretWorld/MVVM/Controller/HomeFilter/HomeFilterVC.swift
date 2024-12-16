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

    @IBOutlet weak var vwTemprary: UIView!
    @IBOutlet weak var vwResult: UIView!
    @IBOutlet weak var tblVwFilter: UITableView!
    @IBOutlet weak var vwApply: UIView!
    
    @IBOutlet weak var lblResult: UILabel!
    private var selectedIndex: Int?
    private var isDropdownVisible = false
    private var arrGigFilter = ["Distance","Price","Completion Time"]
    private var distance = 0
    private var minPrice = 0
    private var maxPrice = 0
    private var minTime = 0
    private var maxTime = 0
     var type:Int = 0
     var lat:Double = 0.0
     var long:Double = 0.0
    var gigType = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tblVwFilter.delegate = self
        tblVwFilter.dataSource = self
        
        tblVwFilter.estimatedRowHeight = 50
        tblVwFilter.rowHeight = UITableView.automaticDimension
    }
    
    func applyFilter(){
        if type == 1{
            //gig
            if Store.GigType == 0 || Store.GigType == 1{
                let param = ["userId": Store.userId ?? "",
                             "lat": lat,
                             "long": long,
                             "radius": distance,
                             "type":type,
                             "gigType":Store.GigType ?? 0,
                             "minHours":1,
                             "maxHours":maxTime,"price_min":1,"price_max":maxPrice] as [String: Any]
                print("Param----", param)
                SocketIOManager.sharedInstance.home(dict: param)
            }else{
                let param = ["userId": Store.userId ?? "",
                             "lat": lat,
                             "long": long,
                             "radius": distance,
                             "type":type, "minHours":1,
                             "maxHours":maxTime,"price_min":1,"price_max":maxPrice] as [String: Any]
                print("Param----", param)
                SocketIOManager.sharedInstance.home(dict: param)
            }
        }else{
            //store
            let param = ["userId": Store.userId ?? "",
                         "lat": lat,
                         "long": long,
                         "radius": distance,
                         "type":type, "minHours":minTime,
                         "maxHours":maxTime,"price_min":minPrice,"price_max":maxPrice] as [String: Any]
            print("Param----", param)
            SocketIOManager.sharedInstance.home(dict: param)
            SocketIOManager.sharedInstance.homeData = { data in
                print("Received data: \(String(describing: data))")
                self.lblResult.text = "Showing \(data?[0].data?.filteredItems?.count ?? 0) results"
                
            }
        }
    }
    @IBAction func actionReset(_ sender: UIButton) {
    }
    
    @IBAction func actionCross(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    @IBAction func actionApply(_ sender: UIButton) {
        applyFilter()
        
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension HomeFilterVC: UITableViewDelegate, UITableViewDataSource {
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
        if indexPath.row == 0 {
            cell.sliderDistance.value = 0
            distance = Int(cell.sliderDistance.value)
            // Add target to handle slider value change
            cell.sliderDistance.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
            let isCurrentRowSelected = (selectedIndex == indexPath.row && isDropdownVisible)
            cell.SliderVw.isHidden = true
            cell.vwDistance.isHidden = !isCurrentRowSelected
            cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
        } else if indexPath.row == 1 {
            cell.sliderDistance.value = 1
            cell.rangeSlider.minValue = 1
            cell.rangeSlider.maxValue = 10000
            cell.rangeSlider.selectedMinValue = 1
            cell.rangeSlider.selectedMaxValue = 10000
        
            minPrice = Int(cell.rangeSlider.selectedMinValue)
            maxPrice = Int(cell.rangeSlider.selectedMaxValue)
            cell.SliderVw.isHidden = true
            cell.vwDistance.isHidden = !isCurrentRowSelected
            cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
            cell.sliderDistance.addTarget(self, action: #selector(sliderValuePrice(_:)), for: .valueChanged)
        } else {
            cell.sliderDistance.value = 1
            cell.rangeSlider.minValue = 1
            cell.rangeSlider.maxValue = 24
            cell.rangeSlider.selectedMinValue = 1
            cell.rangeSlider.selectedMaxValue = 24
          
            minTime = Int(cell.rangeSlider.selectedMinValue)
            maxTime = Int(cell.rangeSlider.selectedMaxValue)
            cell.SliderVw.isHidden = true
            cell.vwDistance.isHidden = !isCurrentRowSelected
            cell.imgVwDropdown.image = UIImage(named: isCurrentRowSelected ? "up" : "down")
            cell.sliderDistance.addTarget(self, action: #selector(sliderValueTime(_:)), for: .valueChanged)
        }

        cell.btnDropDown.tag = indexPath.row
        cell.btnDropDown.addTarget(self, action: #selector(handleDropDown(_:)), for: .touchUpInside)
      
        return cell
    }

    @objc func sliderValueChanged(_ sender: UISlider) {
        distance = Int(sender.value)
        print("Distance Value: \(distance)")
        
    }
    @objc func sliderValuePrice(_ sender: UISlider) {
        maxPrice = Int(sender.value)
        print("Distance Value: \(distance)")
        
    }
    @objc func sliderValueTime(_ sender: UISlider) {
        maxTime = Int(sender.value)
        print("Distance Value: \(distance)")
        
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
