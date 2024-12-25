//
//  GisgsListVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 29/12/23.
//
import UIKit
class GisgsListVC: UIViewController {
    @IBOutlet var heightCollVw: NSLayoutConstraint!
    @IBOutlet var lblNoData: UILabel!
    @IBOutlet var collVwGig: UICollectionView!
    var arrGigList = [GigList]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "GigListCVC", bundle: nil)
        collVwGig.register(nib, forCellWithReuseIdentifier: "GigListCVC")
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("GetStoreServiceData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationUserSide(notification:)), name: Notification.Name("GetStoreUserServices"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        updateHeight()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       updateHeight()
      }
      func updateHeight(){
        let heightInterest = self.collVwGig.collectionViewLayout.collectionViewContentSize.height
          if arrGigList.count > 0 {
              heightCollVw.constant = heightInterest
          }else{
              heightCollVw.constant = 257
          }
        print("HeightGigssss--------",heightCollVw.constant)
        self.view.layoutIfNeeded()
      }
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        uiSet()
    }
    @objc func methodOfReceivedNotificationUserSide(notification: Notification) {
        
        uiSet()
    }
    func uiSet(){
            arrGigList = Store.UserServiceDetailData?.gigs ?? []
        
            if arrGigList.count > 0 {
                lblNoData.isHidden = true
            }else{
                lblNoData.isHidden = false
            }
            collVwGig.reloadData()
            self.updateHeight()
    }
    @IBAction func actionviewAll(_ sender: UIButton) {
    }
}
//MARK: - UICollectionViewDelegate
extension GisgsListVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrGigList.count > 0{
            return arrGigList.count
        }else{
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GigListCVC", for: indexPath) as! GigListCVC
        cell.imgVwGig.layer.cornerRadius = 10
        cell.imgVwGig.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cell.vwShadow.layer.masksToBounds = false
        cell.vwShadow.layer.shadowColor = UIColor(hex: "#5F5F5F").cgColor
        cell.vwShadow.layer.shadowOpacity = 0.44
        cell.vwShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.vwShadow.layer.shouldRasterize = true
        cell.vwShadow.layer.rasterizationScale = UIScreen.main.scale
        cell.vwShadow.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        cell.heightImgVwStartRating.constant = 12
        if arrGigList.count > 0{
            cell.lblName.text = arrGigList[indexPath.row].name ?? ""
            cell.lblPrice.text = "$\(arrGigList[indexPath.row].price ?? 0)"
            cell.lblTitle.text = arrGigList[indexPath.row].title ?? ""
            let rating = arrGigList[indexPath.row].UserRating ?? 0
            let formattedRating = String(format: "%.1f", rating)
            cell.lblRating.text = formattedRating
            cell.lblUserCount.text = "(\(arrGigList[indexPath.row].userRatingCount ?? 0) Review)"
            if  arrGigList[indexPath.row].image == "" ||  arrGigList[indexPath.row].image == nil{
                cell.imgVwGig.image = UIImage(named: "dummy")
            }else{
                cell.imgVwGig.imageLoad(imageUrl: arrGigList[indexPath.row].image ?? "")
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
        Store.isUserParticipantsList = false
        vc.isComing = 0
        vc.gigId = arrGigList[indexPath.row].id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collVwGig.frame.size.width / 2 - 5, height: 215)
    }
}
