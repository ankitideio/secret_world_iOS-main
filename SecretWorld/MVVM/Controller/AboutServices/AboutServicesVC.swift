//
//  AboutServicesVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 23/12/23.
//

import UIKit
import AlignedCollectionViewFlowLayout
class AboutServicesVC: UIViewController {
  @IBOutlet weak var heightImgClsnVw: NSLayoutConstraint!
  @IBOutlet weak var hieghtScrollVw: NSLayoutConstraint!
  @IBOutlet var widthShareBtn: NSLayoutConstraint!
  @IBOutlet var lblLocation: UILabel!
  @IBOutlet var lblrating: UILabel!
  @IBOutlet var lblBusinessName: UILabel!
  @IBOutlet var viewBack: UIView!
  @IBOutlet var imgVwBack: UIImageView!
  @IBOutlet var collVwButtons: UICollectionView!
  @IBOutlet var collVwCategories: UICollectionView!
  @IBOutlet var scrollvw: UIScrollView!
  @IBOutlet var collVwServiceImgs: UICollectionView!
  @IBOutlet weak var widthCollVw: NSLayoutConstraint!
    
  var arrButtons = ["Services","About","Gallery","Review","Gigs"]
  var businessId = ""
  var arrServiceImgs = [String]()
  var viewModelExplore = ExploreVM()
  var arrUserServiceDetail:ServiceDetailsData?
  var arrServiceCategory = [String]()
  var serviceHeight = 0
  var gallaryHeight = 0
  var arrCategoryNames = [String]()
  var isComing = false
    var callBack:((_ indexx:Int)->())?
    var businessIndex = 0
  override func viewDidLoad() {
    super.viewDidLoad()
      let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                 swipeRight.direction = .right
                 view.addGestureRecognizer(swipeRight)
    uiSet()
  }
    @objc func handleSwipe() {
        self.navigationController?.popViewController(animated: true)
        callBack?(businessIndex)
    }
  func uiSet(){
    Store.reviewHeight = 0
    print("serviceId:--\(businessId)")
    let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
    collVwCategories.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
    getServiceDetailApiUserSide()
    if let flowLayout = collVwCategories.collectionViewLayout as? UICollectionViewFlowLayout {
      flowLayout.estimatedItemSize = CGSize(width: 0, height: 37)
      flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
    }
    viewBack.layer.cornerRadius = 20
    viewBack.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    imgVwBack.layer.cornerRadius = 20
    imgVwBack.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
      NotificationCenter.default.addObserver(self, selector: #selector(self.UpdateReview(notification:)), name: Notification.Name("UpdateReview"), object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(self.UpdateAboutText(notification:)), name: Notification.Name("UpdateAboutText"), object: nil)

  }

    
    @objc func UpdateReview(notification: Notification) {

        if let reviewVC = children.first(where: { $0 is ReviewVC }) as? ReviewVC {
                print("--------------", reviewVC.arrReviewUser.count)
            
                if reviewVC.arrReviewUser.count > 0 {
                  self.hieghtScrollVw.constant = CGFloat((reviewVC.heightTblVw.constant))
                }else{
                  self.hieghtScrollVw.constant = 255
                }
              } else {
                print("ReviewVC is not a child of the current view controller.")
              }
        
    }
    @objc func UpdateAboutText(notification: Notification) {

        if let aboutVC = children.first(where: { $0 is AboutVC }) as? AboutVC {
            self.hieghtScrollVw.constant = aboutVC.lblAbout.frame.size.height + 470
            if aboutVC.isSeeMore == false{
                aboutVC.isSeeMore = true
            }else{
                aboutVC.isSeeMore = false
            }
            NotificationCenter.default.post(name: Notification.Name("GetUserAbout"), object: nil)
               } else {
                print("AboutVC is not a child of the current view controller.")
               }
        
    }
  func getServiceDetailApiUserSide(){
      
      viewModelExplore.GetUserServiceDetailApi(user_id: businessId, loader: true) { data in
        Store.recevrID = data?.getBusinessDetails?.id ?? ""
      self.arrUserServiceDetail = data
      Store.getBusinessDetail = data?.getBusinessDetails
      self.imgVwBack.imageLoad(imageUrl: data?.getBusinessDetails?.coverPhoto ?? "")
      self.lblBusinessName.text = data?.getBusinessDetails?.businessname ?? ""
      self.lblLocation.text = data?.getBusinessDetails?.place ?? ""
      let arrCount = data?.allservices?.count ?? 0
      let count = CGFloat(arrCount * 120)
      if data?.allservices?.count ?? 0 == 0{
        self.hieghtScrollVw.constant = 255
        self.serviceHeight = 255
      }else if data?.allservices?.count ?? 0 > 2{
        self.hieghtScrollVw.constant = 240 + 80
        self.serviceHeight = 320
      }else{
        self.hieghtScrollVw.constant = count + 80
        self.serviceHeight = Int(count + 80)
      }
     
      if data?.serviceImagesArray?.count ?? 0 > 0{
        self.gallaryHeight = 250
        self.heightImgClsnVw.constant = 60
          if self.widthCollVw.constant < self.view.frame.size.width{
              self.widthCollVw.constant = CGFloat((data?.serviceImagesArray?.count ?? 0)*63)
              
          }else{
              self.widthCollVw.constant = self.view.frame.size.width - 40
              
          }
          
        self.collVwServiceImgs.isHidden = false
      }else{
        self.gallaryHeight = 255
        self.heightImgClsnVw.constant = 0
        self.collVwServiceImgs.isHidden = true
      }
        print("Height-----",self.hieghtScrollVw.constant)
      if let rating = data?.getBusinessDetails?.rating {
        let formattedRating = String(format: "%.1f", rating)
        let ratingCount = data?.getBusinessDetails?.ratingCount ?? 0
          if ratingCount > 1{
              self.lblrating.text = "\(formattedRating) (\(ratingCount) Reviews)"
          }else{
              self.lblrating.text = "\(formattedRating) (\(ratingCount) Review)"
          }
      }
      self.arrCategoryNames = data?.getBusinessDetails?.categoryName ?? []
      self.arrServiceImgs = data?.serviceImagesArray ?? []
        print("serviceImagesArray-----",data?.serviceImagesArray ?? [])
        
      self.collVwCategories.reloadData()
      self.collVwServiceImgs.reloadData()
    }
  }
  
  @IBAction func actionBack(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
      callBack?(businessIndex)
  }
  @IBAction func actionShare(_ sender: UIButton) {
  }
}
//MARK: - UICollectionViewDelegate
extension AboutServicesVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == collVwServiceImgs{
      return arrServiceImgs.count
        
    }else if collectionView == collVwButtons{
      return arrButtons.count
    }else{
      return arrCategoryNames.count
    }
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == collVwServiceImgs{
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServicesImagesCVC", for: indexPath) as! ServicesImagesCVC
      cell.imgVwServices.imageLoad(imageUrl: arrServiceImgs[indexPath.row])
        if arrServiceImgs.count > 5{
            
            if indexPath.row == 4{
              cell.viewShadow.isHidden = false
              cell.lblImgCount.isHidden = false
              cell.lblImgCount.text = "+\(arrServiceImgs.count - 5)"
            }else{
                cell.viewShadow.isHidden = true
                cell.lblImgCount.isHidden = true
            }
            
        }else{
            
            cell.viewShadow.isHidden = true
            cell.lblImgCount.isHidden = true
        }
     
      return cell
    }else if collectionView == collVwButtons{
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonsCVC", for: indexPath) as! ButtonsCVC
      cell.viewSeprator.isHidden = indexPath.row != 0
      cell.lblTitle.text = arrButtons[indexPath.row]
      if indexPath.item == 0{
        cell.lblTitle.textColor = .app
      }else{
        cell.lblTitle.textColor = .black
      }
      return cell
    }else
    {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
      cell.lblName.numberOfLines = 1
      cell.lblName.text = arrCategoryNames[indexPath.item]
      cell.vwBg.cornerRadiusView = 4
      cell.widthBtnCross.constant = 0
      cell.lblName.textColor = .app
      return cell
    }
  }
  func updateViewForSelectedSegment(_ selectedIndex: Int) {
      isCall = false
    switch selectedIndex {
    case 1:
     
        if let aboutVC = children.first(where: { $0 is AboutVC }) as? AboutVC {
            NotificationCenter.default.post(name: Notification.Name("GetUserAbout"), object: nil)
              self.hieghtScrollVw.constant = aboutVC.lblAbout.frame.size.height + 470
               } else {
                print("AboutVC is not a child of the current view controller.")
               }
      scrollvw.setContentOffset(CGPoint(x: scrollvw.frame.size.width * 1, y: 1), animated: false)
    case 2:
    
      self.hieghtScrollVw.constant = CGFloat(gallaryHeight)
      scrollvw.setContentOffset(CGPoint(x: scrollvw.frame.size.width * 2, y: 2), animated: false)
    case 3:
        NotificationCenter.default.post(name: Notification.Name("review"), object: nil)
        if let reviewVC = children.first(where: { $0 is ReviewVC }) as? ReviewVC {
                print("--------------", reviewVC.arrReviewUser.count)
            
                if reviewVC.arrReviewUser.count > 0 {
                  self.hieghtScrollVw.constant = CGFloat((reviewVC.heightTblVw.constant))
                }else{
                  self.hieghtScrollVw.constant = 255
                }
              } else {
                print("ReviewVC is not a child of the current view controller.")
              }
        
      scrollvw.setContentOffset(CGPoint(x: scrollvw.frame.size.width * 3, y: 3), animated: false)
    case 4:
     
      if arrUserServiceDetail?.gigs?.count ?? 0 > 0{
          if let gigsVC = children.first(where: { $0 is GisgsListVC }) as? GisgsListVC {
               self.hieghtScrollVw.constant = CGFloat((gigsVC.heightCollVw.constant+40))
             } else {
              print("ReviewVC is not a child of the current view controller.")
             }
       
         }else{
          self.hieghtScrollVw.constant = 255
         }
     
      scrollvw.setContentOffset(CGPoint(x: scrollvw.frame.size.width * 4, y: 4), animated: false)
    default:
 
      self.hieghtScrollVw.constant = CGFloat(self.serviceHeight)
      scrollvw.setContentOffset(.zero, animated: false)
    }
  }
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == collVwButtons {
      for visibleIndexPath in collectionView.indexPathsForVisibleItems {
        if let cell = collectionView.cellForItem(at: visibleIndexPath) as? ButtonsCVC {
          cell.viewSeprator.isHidden = visibleIndexPath != indexPath
          cell.lblTitle.textColor = visibleIndexPath == indexPath ? .app : .black
        }
      }
      if indexPath.item == 3 {
        collectionView.scrollToItem(at: IndexPath(item: 4, section: 0), at: .right, animated: true)
      }else if indexPath.item == 1{
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .right, animated: true)
      }else if indexPath.item == 2{
         // self.uiSet()
      }
      updateViewForSelectedSegment(indexPath.item)
    }else if collectionView == collVwServiceImgs{
        if arrServiceImgs.count > 5{
            if indexPath.item == 4 {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServiceImagesVC") as! ServiceImagesVC
                vc.arrServiceImgs = arrServiceImgs
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == collVwServiceImgs{
        return CGSize(width: collVwButtons.frame.size.width/5-4, height: 50)
    }else if collectionView == collVwButtons{
      return CGSize(width: collVwButtons.frame.size.width / 4 - 10, height: 35)
    }else
    {
      return CGSize(width: collVwCategories.frame.size.width / 4 + 10, height: 30)
    }
  }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collVwServiceImgs{
            return 0
        }else {
            return 10
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collVwServiceImgs{
            return 0
        }else {
            return 10
        }
    }
}
