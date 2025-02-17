//
//  AboutServicesVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 23/12/23.
//

import UIKit
import AlignedCollectionViewFlowLayout
class AboutServicesVC: UIViewController {
    @IBOutlet weak var vwOffer: UIView!
    @IBOutlet weak var heightOfferVw: NSLayoutConstraint!
    @IBOutlet weak var topOfferVw: NSLayoutConstraint!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var widthBlueTick: NSLayoutConstraint!
    @IBOutlet weak var widthRatingBatch: NSLayoutConstraint!
    @IBOutlet var imgVwStore: UIImageView!
    @IBOutlet var pageController: UIPageControl!
    @IBOutlet var lblOfferCount: UILabel!
    @IBOutlet var collVwOffer: UICollectionView!
    @IBOutlet var viewBAckGreen: UIView!
    @IBOutlet var viewCall: UIView!
    @IBOutlet var viewDirection: UIView!
    @IBOutlet var lblRating: UILabel!
    @IBOutlet var lblratingCount: UILabel!
    @IBOutlet var lblTiming: UILabel!
    @IBOutlet var lblLOcation: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var viewStoreDetail: UIView!
    @IBOutlet weak var hieghtScrollVw: NSLayoutConstraint!
    @IBOutlet var collVwButtons: UICollectionView!
    @IBOutlet var collVwCategories: UICollectionView!
    @IBOutlet var scrollvw: UIScrollView!
    
  var arrButtons = ["Services","About","Gallery","Review","Tasks"]
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
  var getDay:String?
  var isOpen = false
  var arrOffers = [businessDeals]()
  var timer: Timer?
  var currentIndex = 0
  
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
      addTapGestureToViews(views: [viewCall, viewDirection], target: self, action: #selector(handleTapViewCall))
      let currentDay = getCurrentDay()
      getDay = currentDay
      print("Current day: \(currentDay)")
      viewBAckGreen.layer.cornerRadius = 35
      viewBAckGreen.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
      applyShadow(to: [viewCall,viewDirection,viewStoreDetail])
    Store.reviewHeight = 0
    print("serviceId:--\(businessId)")
    let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
    collVwCategories.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
      
      let nib2 = UINib(nibName: "OfferCVC", bundle: nil)
      collVwOffer.register(nib2, forCellWithReuseIdentifier: "OfferCVC")

    getServiceDetailApiUserSide()
    if let flowLayout = collVwCategories.collectionViewLayout as? UICollectionViewFlowLayout {
      flowLayout.estimatedItemSize = CGSize(width: 0, height: 37)
      flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
    }
      NotificationCenter.default.addObserver(self, selector: #selector(self.UpdateReview(notification:)), name: Notification.Name("UpdateReview"), object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(self.UpdateAboutText(notification:)), name: Notification.Name("UpdateAboutText"), object: nil)

  }
    @objc func handleTapViewCall(sender: UITapGestureRecognizer) {
        if let tappedView = sender.view {
            if tappedView == viewCall {
                print("viewCall tapped!")
            }else{
                print("viewDirection tapped!")
            }
        }
    }

    func addTapGestureToViews(views: [UIView], target: Any, action: Selector) {
        for view in views {
            let tapGesture = UITapGestureRecognizer(target: target, action: action)
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(tapGesture)
        }
    }

    func getCurrentDay() -> String {
       let date = Date() // Get the current date
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "EEEE" // Format to get the full day name
       return dateFormatter.string(from: date).lowercased() // Convert to lowercase
   }

    private func applyShadow(to views: [UIView]) {
        for view in views {
            view.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor // #00000026 equals ~15% opacity
            view.layer.shadowOffset = CGSize(width: 0, height: 2) // (0px 2px)
            view.layer.shadowOpacity = 1 // Full shadow opacity
            view.layer.shadowRadius = 4 // Blur radius
            view.layer.masksToBounds = false
        }
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
          
          if let rating = data?.getBusinessDetails?.ratingCount {
              if rating > 4 {
                  self.widthRatingBatch.constant = 18
              } else if rating == 4 {
                  self.widthRatingBatch.constant = 18
              } else {
                  self.widthRatingBatch.constant = 0
              }
          }
          if data?.getBusinessDetails?.category == 1{
              self.lblCategory.text = "Restaurants"
          }else  if data?.getBusinessDetails?.category == 2{
              self.lblCategory.text = "Retail"
          }else  if data?.getBusinessDetails?.category == 3{
              self.lblCategory.text = "Beauty & wellness"
          }else{
              self.lblCategory.text = "Events"
          }
          
          if data?.getBusinessDetails?.businessDeals?.count ?? 0 > 0{
              self.vwOffer.isHidden = false
              self.topOfferVw.constant = 25
              self.heightOfferVw.constant = 54
              self.arrOffers = data?.getBusinessDetails?.businessDeals ?? []
              self.pageController.numberOfPages = data?.getBusinessDetails?.businessDeals?.count ?? 0
              self.pageController.currentPage = 0
             
              self.collVwOffer.reloadData()
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                     if self.arrOffers.count > 1 {
                         self.lblOfferCount.text = "1/\(self.arrOffers.count)"
                         self.startAutoScroll() // Ensure it starts after reload
                     }
                 }
          }else{
              self.vwOffer.isHidden = true
              self.topOfferVw.constant = 5
              self.heightOfferVw.constant = 0
          }
        Store.recevrID = data?.getBusinessDetails?.id ?? ""
      self.arrUserServiceDetail = data
      Store.getBusinessDetail = data?.getBusinessDetails
          self.lblName.text = data?.getBusinessDetails?.name ?? ""
          self.lblLOcation.text = data?.getBusinessDetails?.place ?? ""
          self.imgVwStore.imageLoad(imageUrl: data?.getBusinessDetails?.profilePhoto ?? "")
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
      }else{
        self.gallaryHeight = 255
      }
          self.lblRating.text = "\(data?.getBusinessDetails?.rating ?? 0)"
          if let rating = data?.getBusinessDetails?.rating {
              let ratingCount = data?.getBusinessDetails?.ratingCount ?? 0
              let formattedRatingCount = self.formatUsedCount(ratingCount)
              if ratingCount > 1 {
                  self.lblratingCount.text = "\(formattedRatingCount) Ratings"
              } else {
                  self.lblratingCount.text = "\(formattedRatingCount) Rating"
              }
          }
          self.arrCategoryNames = data?.getBusinessDetails?.typesOfCategoryDetails ?? []
      self.arrServiceImgs = data?.serviceImagesArray ?? []
          self.collVwCategories.reloadData()
          print("isOpen:-\(self.isOpen)")
          for businessTiming in data?.getBusinessDetails?.openingHours ?? [] {
              if businessTiming.day == self.getDay {
                  if businessTiming.starttime == ""{
                      self.lblTiming.text = "Closed today"
                  }else{
                      let openTime = self.convertTo12HourFormat(businessTiming.endtime ?? "")
                      self.lblTiming.text = "Open till \(openTime)"
                  }
                  break
              }
          }
    }
   
  }
    func formatUsedCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return "\(count / 1_000_000)M+"
        } else if count >= 1_000 {
            return "\(count / 1_000)K+"
        } else if count % 100 == 0 {
            return "\(count)"
        } else if count > 100 {
            return "\(count / 100 * 100)+"
        } else {
            return "\(count)"
        }
    }

    func startAutoScroll() {
        // Invalidate any existing timer to avoid multiple timers running.
        timer?.invalidate()
        
        // Start a new timer to auto-scroll every 2 seconds
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(scrollToNextItem), userInfo: nil, repeats: true)
    }
    @objc func scrollToNextItem() {
        guard arrOffers.count > 1 else { return } // Prevent scrolling if there's only one item

        if currentIndex < arrOffers.count - 1 {
            currentIndex += 1
            self.lblOfferCount.text = "\(currentIndex+1)/\(self.arrOffers.count)"
        } else {
            currentIndex = 0 // Loop back to the first item
            self.lblOfferCount.text = "1/\(self.arrOffers.count)"
        }
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        
        DispatchQueue.main.async {
            self.collVwOffer.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.pageController.currentPage = self.currentIndex // Update page control
            self.collVwOffer.collectionViewLayout.invalidateLayout()
               self.collVwOffer.layoutIfNeeded()
        }
    }
    deinit {
          timer?.invalidate()
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
    if collectionView == collVwButtons{
      return arrButtons.count
    }else if collectionView == collVwCategories{
      return arrCategoryNames.count
        
    }else{
        return arrOffers.count
    }
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  if collectionView == collVwButtons{
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonsCVC", for: indexPath) as! ButtonsCVC
      cell.viewSeprator.isHidden = indexPath.row != 0
      cell.lblTitle.text = arrButtons[indexPath.row]
      if indexPath.item == 0{
        cell.lblTitle.textColor = .app
      }else{
        cell.lblTitle.textColor = .black
      }
      return cell
  }else if collectionView == collVwCategories{
    
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
      cell.lblName.numberOfLines = 1
      cell.lblName.text = arrCategoryNames[indexPath.item]
      cell.vwBg.cornerRadiusView = 4
        cell.vwBg.backgroundColor = UIColor(hex: "#E6F2E5")
      cell.widthBtnCross.constant = 0
        cell.lblName.textColor = .black
      return cell
  }else{
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCVC", for: indexPath) as! OfferCVC
      cell.lblTitle.text = arrOffers[indexPath.row].title ?? ""
      
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
    }
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == collVwButtons{
      return CGSize(width: collVwButtons.frame.size.width / 4 - 10, height: 35)
    }else if collectionView == collVwCategories{
      return CGSize(width: collVwCategories.frame.size.width / 4 + 10, height: 22)
    }else{
        return CGSize(width: collVwOffer.frame.size.width, height: 22)
    }
  }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 10
    }
    
}
extension AboutServicesVC {
    func convertTo12HourFormat(_ time24: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if let date24 = dateFormatter.date(from: time24) {
            dateFormatter.dateFormat = "h:mm a"
            let time12 = dateFormatter.string(from: date24)
            return time12
        }
        
        return ""
    }
}
