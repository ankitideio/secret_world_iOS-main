//
//  GigPopupViewVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 29/11/24.
//

import UIKit
import Hero

class GigPopupViewVC: UIViewController {
    //MARK: - IBOutlet
    @IBOutlet var collVwGigList: UICollectionView!
    //MARK: - Variables
    var isSelectBtn = 0
    var callBack:((_ isSelect:Int?,_ isChat:Bool,_ gigData:GetUserGigData?,_ userGig:Bool)->())?
    var arrData = [FilteredItem]()
    var currentIndex = 0
    var selectedId = ""
    var viewModel = AddGigVM()
    var data:GetUserGigData?
    var callBackCancel:(()->())?
    var arrParticipanstList = [Participantzz]()
    var isUserGig = false
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
        getGigDetailApi(selectId: selectedId)
    }
    
    private func getGigDetailApi(selectId: String) {
        viewModel.GetPopUpGigDetailApi(gigId: selectId) { data in
            DispatchQueue.main.async {
                guard let data = data else { return }
                self.data = data
                self.arrParticipanstList = data.participantsList ?? []
                self.updateCellData()
            }
        }
    }

    private func updateCellData() {
        // Reload the collection view to display updated data
        self.collVwGigList.reloadData()
    }
    private func uiSet() {
       // setupTapGesture()
        if let index = arrData.firstIndex(where: { $0.id == selectedId }) {
            currentIndex = index
        }
        let nibCollvw = UINib(nibName: "GigViewCVC", bundle: nil)
        collVwGigList.register(nibCollvw, forCellWithReuseIdentifier: "GigViewCVC")
        collVwGigList.delegate = self // Set delegate
        collVwGigList.reloadData()
        DispatchQueue.main.async {
            self.scrollToCurrentIndex()
        }
    }
    private func scrollToCurrentIndex() {
        collVwGigList.layoutIfNeeded()
        if arrData.indices.contains(currentIndex) {
            let indexPath = IndexPath(item: currentIndex, section: 0)
            collVwGigList.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            Store.CurrentUserId = arrData[indexPath.row].userID ?? ""
            getGigDetailApi(selectId: arrData[indexPath.row].id ?? "")
        }
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        // Ignore touches on collection view
        tapGesture.delegate = self
    }
       @objc private func dismissView() {
           dismiss(animated: true, completion: nil)
       }
    @IBAction func actionLeftClick(_ sender: UIButton) {
        if currentIndex > 0 {
                    currentIndex -= 1
                    scrollToCurrentIndex()
           
                }
    }
    @IBAction func actionRightClick(_ sender: UIButton) {
        if currentIndex < arrData.count - 1 {
                    currentIndex += 1
                    scrollToCurrentIndex()
          
                }
    }
}

//MARK: - UICollectionViewDataSource,UICollectionViewDelegate
extension GigPopupViewVC: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrData.count > 0{
            return arrData.count
        }else{
            return 0
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GigViewCVC", for: indexPath) as! GigViewCVC
        if let gigData = data {
            cell.arrParticipanstList = arrParticipanstList
            cell.uiSet()
            if gigData.gig?.totalParticipants ?? "" == "0"{
                cell.lblParticipants.text = "No Participants"
            }else if  gigData.gig?.totalParticipants ?? "" == "1"{
                cell.lblParticipants.text = "Participant: \(gigData.gig?.totalParticipants ?? "")"
            }else{
                cell.lblParticipants.text = "Participants: \(gigData.gig?.totalParticipants ?? "")"
            }
            
            cell.lblParticipantsCount.text = "Spots: (\(gigData.appliedParticipants ?? 0)/\(gigData.gig?.totalParticipants ?? ""))"
            // Bind gig data to cell
            let priceText = "Payout: $\(gigData.gig?.price ?? 0)"
            let attributedString = NSMutableAttributedString(string: priceText)
            if let priceRange = priceText.range(of: "$\(gigData.gig?.price ?? 0)") {
                let nsRange = NSRange(priceRange, in: priceText)
                attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 14)], range: nsRange)
            }
            cell.lblPayout.attributedText = attributedString
            

            // Assuming `gigData.gig?.place`, `gigData.gig?.serviceDuration`, and `gigData.gig?.serviceName` have values

            // For lblLocation
            let locationText = "Location: \(gigData.gig?.place ?? "")"
            let locationBoldText = "Location: "
            let locationNormalText = gigData.gig?.place ?? ""

            let locationAttributedString = NSMutableAttributedString()

            // Bold part for "Location:"
            let boldAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 11) // Adjust font size as needed
            ]
            let boldLocation = NSAttributedString(string: locationBoldText, attributes: boldAttributes)
            locationAttributedString.append(boldLocation)

            // Normal part (place name)
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11) // Adjust font size as needed
            ]
            let normalLocation = NSAttributedString(string: locationNormalText, attributes: normalAttributes)
            locationAttributedString.append(normalLocation)

            // Set the attributed text to the label
            cell.lblLocation.attributedText = locationAttributedString


            // For lblTaskDuration
            let taskDurationText = "Task Duration: \(gigData.gig?.serviceDuration ?? "")"
            let taskDurationBoldText = "Task Duration: "
            let taskDurationNormalText = gigData.gig?.serviceDuration ?? ""

            let taskDurationAttributedString = NSMutableAttributedString()

            // Bold part for "Task Duration:"
            let boldTaskDuration = NSAttributedString(string: taskDurationBoldText, attributes: boldAttributes)
            taskDurationAttributedString.append(boldTaskDuration)

            // Normal part (service duration)
            let normalTaskDuration = NSAttributedString(string: taskDurationNormalText, attributes: normalAttributes)
            taskDurationAttributedString.append(normalTaskDuration)

            // Set the attributed text to the label
            cell.lblTaskDuration.attributedText = taskDurationAttributedString


            // For lblServiceName (same as Task Duration)
            let serviceNameText = "Task Duration: \(gigData.gig?.serviceName ?? "")"
            let serviceNameBoldText = "Task Duration: "
            let serviceNameNormalText = gigData.gig?.serviceName ?? ""

            let serviceNameAttributedString = NSMutableAttributedString()

            // Bold part for "Task Duration:"
            let boldServiceName = NSAttributedString(string: serviceNameBoldText, attributes: boldAttributes)
            serviceNameAttributedString.append(boldServiceName)

            // Normal part (service name)
            let normalServiceName = NSAttributedString(string: serviceNameNormalText, attributes: normalAttributes)
            serviceNameAttributedString.append(normalServiceName)

            // Set the attributed text to the label
            cell.lblServiceName.attributedText = serviceNameAttributedString

            let startDate = gigData.gig?.startDate ?? ""
            // Create a DateFormatter to parse the ISO 8601 string
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoDateFormatter.date(from: startDate) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MMM-yyyy"
                let formattedDate = dateFormatter.string(from: date)
                dateFormatter.dateFormat = "hh:mm a"
                let formattedTime = dateFormatter.string(from: date)
                let timeText = "Time: \(formattedTime)"
                let dateText = "Date: \(formattedDate)"

                // Create an NSMutableAttributedString for the "Time" label
                let timeAttributedString = NSMutableAttributedString(string: timeText)
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize:11) // Adjust the font size as needed
                ]
                // Apply bold to "Time:"
                timeAttributedString.addAttributes(boldAttributes, range: NSRange(location: 0, length: 5))

                // Set the attributed string to the label
                cell.lblTime.attributedText = timeAttributedString
                
                // Create an NSMutableAttributedString for the "Date" label
                let dateAttributedString = NSMutableAttributedString(string: dateText)
                // Apply bold to "Date:"
                dateAttributedString.addAttributes(boldAttributes, range: NSRange(location: 0, length: 5))

                // Set the attributed string to the label
                cell.lblDate.attributedText = dateAttributedString
            } else {
                print("Invalid date format")
            }
            
            cell.lblGigName.text = gigData.gig?.title ?? ""
            cell.lblNameProvider.text = "Mr.\(gigData.gig?.name ?? "")"
            if gigData.gig?.image == "" || gigData.gig?.image == nil{
                cell.imgVwServiceProvider.image = UIImage(named: "dummy")
            }else{
                cell.imgVwServiceProvider.imageLoad(imageUrl: gigData.gig?.image ?? "")
            }
            cell.btnApply.tag = indexPath.row
            cell.btnApply.addTarget(self, action: #selector(actionApply), for: .touchUpInside)
            if gigData.gig?.user?.id == Store.userId{
                cell.btnApply.setTitle("Edit Gig", for: .normal)
                isUserGig = true
            }else{
                cell.btnApply.setTitle("View More", for: .normal)
                isUserGig = false
            }
//            switch gigData.status {
//            case 0:
//                cell.btnApply.setTitle("Requested", for: .normal)
//                cell.btnApply.backgroundColor = UIColor(red: 255/255, green: 230/255, blue: 182/255, alpha: 1.0)
//                cell.btnApply.setTitleColor(UIColor(red: 255/255, green: 178/255, blue: 30/255, alpha: 1.0), for: .normal)
//                cell.btnApply.isUserInteractionEnabled = false
//                cell.btnChat.isHidden = true
//                
//            case 1:
//                cell.btnChat.tag = indexPath.row
//                cell.btnChat.addTarget(self, action: #selector(actionChat), for: .touchUpInside)
//
//                cell.btnApply.isHidden = true
//                cell.btnChat.isHidden = false
//                
//            case 2:
//                cell.btnApply.isHidden = false
//                let title = gigData.isReview == true ? "Update review" : "Add review"
//                cell.btnApply.setTitle(title, for: .normal)
//                cell.btnApply.backgroundColor = UIColor.app
//                cell.btnApply.setTitleColor(UIColor.white, for: .normal)
//                cell.btnChat.isHidden = true
//                
//            default:
//                cell.btnApply.isUserInteractionEnabled = true
//                cell.btnApply.tag = indexPath.row
//                cell.btnApply.addTarget(self, action: #selector(actionApply), for: .touchUpInside)
//                cell.btnApply.isHidden = false
//                cell.btnApply.setTitle("Apply Now", for: .normal)
//                cell.btnApply.backgroundColor = UIColor.app
//                cell.btnApply.setTitleColor(UIColor.white, for: .normal)
//                cell.btnChat.isHidden = true
//            }
            cell.btnDismiss.tag = indexPath.row
            cell.btnDismiss.addTarget(self, action: #selector(actionDismiss), for: .touchUpInside)
            cell.btnViewMore.tag = indexPath.row
            cell.btnViewMore.addTarget(self, action: #selector(actionViewMore), for: .touchUpInside)
            cell.btnShare.tag = indexPath.row
            cell.btnShare.addTarget(self, action: #selector(actionShare), for: .touchUpInside)
            //cell.btnChat.isHidden = gigData.status != 1
        }
        return cell
    }
 
    @objc func actionShare(sender:UIButton){
        let deepLinkURL = URL(string: "https://api.secretworld.ai/taskId/676982526d9ff3ef55c365bd")!
        print(deepLinkURL)
               // Initialize UIActivityViewController
               let activityViewController = UIActivityViewController(activityItems: [deepLinkURL], applicationActivities: nil)
               
               // Exclude certain activities if needed
               activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList]
               
               // Present the activity view controller
               present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func actionDismiss(sender:UIButton){
        self.dismiss(animated: true)
        callBackCancel?() 
        
    }
    @objc func actionChat(sender:UIButton){
        self.dismiss(animated: true)
        callBack?(0,true,data, isUserGig)
    }
    @objc func actionViewMore(sender:UIButton){
        self.dismiss(animated: true)
        callBack?(1,false, data, isUserGig)

    }
    @objc func actionApply(sender:UIButton){
        
        self.dismiss(animated: true)
        callBack?(0,false,data, isUserGig)
  
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == collVwGigList else { return }
        
        let visibleCells = collVwGigList.visibleCells
        if let firstCell = visibleCells.first,
           let indexPath = collVwGigList.indexPath(for: firstCell) {
            
            // Access the gig ID of the currently visible item
            let gigId = arrData[indexPath.item].id ?? ""
            print("Current Gig ID: \(gigId)")
            Store.CurrentUserId = arrData[indexPath.item].userID ?? ""
            // Avoid redundant API calls for the same gig ID 
            if selectedId != gigId {
                selectedId = gigId
                getGigDetailApi(selectId: gigId)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collVwGigList.frame.size.width, height: 375)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension GigPopupViewVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Prevent gesture recognizer from triggering when touching buttons
        if let view = touch.view, view is UIButton {
            return false
        }
        return true
    }
}
