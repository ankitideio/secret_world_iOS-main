//
//  PopularAndNearServiceVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 26/12/23.
//

import UIKit

class PopularAndNearServiceVC: UIViewController {

    
    @IBOutlet var heightTblVw: NSLayoutConstraint!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var tblVwServices: UITableView!
    @IBOutlet var collVwCategory: UICollectionView!
    @IBOutlet var txtFldSearch: UITextField!
    //MARK: - Varibales
    var serviceCategories: [ServiceCategory] = [
        ServiceCategory(name: "Cleaning", imageName: "Cleaning"),
        ServiceCategory(name: "Repairing", imageName: "Repairing"),
        ServiceCategory(name: "Plumbing", imageName: "Plumbing"),
        ServiceCategory(name: "Shifting", imageName: "Shifting"),
        ServiceCategory(name: "Food", imageName: "Food"),
        ServiceCategory(name: "Painting", imageName: "Painting"),
        ServiceCategory(name: "Laundry", imageName: "Laundry"),
        ServiceCategory(name: "AC Repair", imageName: "AC Repair"),
        ServiceCategory(name: "Car Repair", imageName: "Car Repair"),
        ServiceCategory(name: "Electrician", imageName: "Electrician"),
        ServiceCategory(name: "Carpainter", imageName: "Carpainter"),
        ServiceCategory(name: "Iron", imageName: "Iron"),
        ServiceCategory(name: "Beauty", imageName: "Beauty"),
        ServiceCategory(name: "Gardening", imageName: "Gardening"),
        ServiceCategory(name: "Security", imageName: "Security"),
        ServiceCategory(name: "Events", imageName: "Events")
    ]
     var isComing = false
    override func viewDidLoad() {
        super.viewDidLoad()
      uiSet()
    }
    func uiSet(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                   swipeRight.direction = .right
                   view.addGestureRecognizer(swipeRight)

        let nibNearBy = UINib(nibName: "ServicesNearByTVC", bundle: nil)
        tblVwServices.register(nibNearBy, forCellReuseIdentifier: "ServicesNearByTVC")
        let nib = UINib(nibName: "CategoriesCVC", bundle: nil)
               collVwCategory.register(nib, forCellWithReuseIdentifier: "CategoriesCVC")
        if isComing == true{
            lblTitle.text = "Popular Services"
            heightTblVw.constant = CGFloat(5*120)
        }else{
            lblTitle.text = "Services near by"
            heightTblVw.constant = CGFloat(5*120)
        }
    }
    @objc func handleSwipe() {
               navigationController?.popViewController(animated: true)
           }

    @IBAction func actionSeeAllCategory(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AllCategoryVC") as! AllCategoryVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionFilter(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FiltersVC") as! FiltersVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
   

}
//MARK: - UICollectionViewDelegate
extension PopularAndNearServiceVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
            return serviceCategories.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCVC", for: indexPath) as! CategoriesCVC
            let category = serviceCategories[indexPath.row]
        cell.imgVwCategory.image = UIImage(named: category.imageName)
            cell.lblName.text = category.name
            return cell
            
        
        
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
       
            return CGSize(width: collVwCategory.frame.size.width / 5, height: 100)
            
       
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailVC") as! EventDetailVC
//
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: -UITableViewDelegate
extension PopularAndNearServiceVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return  5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServicesNearByTVC", for: indexPath) as! ServicesNearByTVC
        
          cell.viewShadow.layer.masksToBounds = false
          cell.viewShadow.layer.shadowColor = UIColor.black.cgColor
          cell.viewShadow.layer.shadowOpacity = 0.1
          cell.viewShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
          cell.viewShadow.layer.shouldRasterize = true
          cell.viewShadow.layer.rasterizationScale = UIScreen.main.scale
           cell.viewShadow.layer.cornerRadius = 10
        cell.btnBookMark.addTarget(self, action: #selector(actionBookMark), for: .touchUpInside)
        cell.heighViewServiceNames.constant = 0
        cell.lblPrice.text = ""
        return cell
    }
    @objc func actionBookMark(sender:UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected != true{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RemoveBookMarkVC") as! RemoveBookMarkVC
            vc.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
          return  120
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AboutServicesVC") as! AboutServicesVC
        navigationController?.pushViewController(vc, animated: true)
    }
}
