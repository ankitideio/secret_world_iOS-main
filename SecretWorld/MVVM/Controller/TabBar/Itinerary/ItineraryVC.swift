//
//  ItineraryVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 02/01/25.
//

import UIKit
import FSCalendar
import CalendarKit

class ItineraryVC: UIViewController {
    //MARK: - IBOutlet
    @IBOutlet var eventView: UIView!
    @IBOutlet var calenderVw: FSCalendar!
    @IBOutlet var btnCalendrTyp: UIButton!
    
    //MARK: - variables
    private var dayView: DayView!
    private var eventsDictionary: [Date: [Event]] = [:]
    //MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
        setupDayView()
    }
    // MARK: - Setup UI
    private func uiSet() {
            calenderVw.isHidden = false
            eventView.isHidden = true
            calenderVw.delegate = self
            calenderVw.dataSource = self
            calenderVw.headerHeight = 0
            // Customize calendar appearance if needed
            calenderVw.appearance.titleDefaultColor = .black
            calenderVw.appearance.headerTitleColor = .red
            calenderVw.appearance.weekdayTextColor = UIColor(hex: "#5A5A5A")
            calenderVw.appearance.selectionColor = UIColor.app
        }
    private func setupDayView() {
        dayView = DayView()
        dayView.translatesAutoresizingMaskIntoConstraints = false
        eventView.addSubview(dayView)

        // Add constraints to make dayView fill eventView
        NSLayoutConstraint.activate([
            dayView.topAnchor.constraint(equalTo: eventView.topAnchor),
            dayView.bottomAnchor.constraint(equalTo: eventView.bottomAnchor),
            dayView.leadingAnchor.constraint(equalTo: eventView.leadingAnchor),
            dayView.trailingAnchor.constraint(equalTo: eventView.trailingAnchor)
        ])

        // Set the DayView's delegate to self
        dayView.delegate = self
        dayView.dataSource = self
        dayView.reloadData()
    }
    @IBAction func actionAdd(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateItineraryVC") as! CreateItineraryVC
        vc.modalPresentationStyle = .overFullScreen
        vc.callBack = { [weak self] title, date, time in
            if let event = self?.createEvent(title: title, date: date, time: time) {
                self?.addEvent(event)
                self?.dayView.reloadData()
            }
        }
        self.present(vc, animated: true)
        
    }
    @IBAction func actionCalenderType(_ sender: UIButton) {
            view.endEditing(true)
            let vc = storyboard?.instantiateViewController(withIdentifier: "GigPopOversVC") as! GigPopOversVC
            vc.type = "calender"
            vc.callBack = {[weak self] type,title,id in

                if title == "Weekly"{
                    self?.calenderVw.isHidden = true
                    self?.eventView.isHidden = false
                }else{
                    self?.calenderVw.isHidden = false
                    self?.eventView.isHidden = true
                }

            }
            vc.modalPresentationStyle = .popover
            let popOver : UIPopoverPresentationController = vc.popoverPresentationController!
            popOver.sourceView = sender
            popOver.delegate = self
            popOver.permittedArrowDirections = .up
            vc.preferredContentSize = CGSize(width: btnCalendrTyp.frame.size.width, height: 100)
            self.present(vc, animated: false)
        
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK: - EventDataSource
extension ItineraryVC:EventDataSource,DayViewDelegate {
    func dayViewDidSelectEventView(_ eventView: CalendarKit.EventView) {
        print("dayViewDidSelectEventView")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateItineraryVC") as! CreateItineraryVC
        vc.modalPresentationStyle = .overFullScreen
        // Access the event descriptor and retrieve the title
        if let eventDescriptor = eventView.textView as? UITextView {
            vc.getTitle = eventDescriptor.text // Pass the event title here
        }
        vc.callBack = { [weak self] title, date, time in
            if let event = self?.createEvent(title: title, date: date, time: time) {
                self?.addEvent(event)
                self?.dayView.reloadData()
            }
        }
        self.present(vc, animated: true)
        
    }
    
    func dayViewDidLongPressEventView(_ eventView: CalendarKit.EventView) {
        print("dayViewDidLongPressEventView")
    }
    
    func dayView(dayView: CalendarKit.DayView, didTapTimelineAt date: Date) {
        print("didTapTimelineAt")
    }
    
    func dayView(dayView: CalendarKit.DayView, didLongPressTimelineAt date: Date) {
        print("didLongPressTimelineAt")
    }
    
    func dayViewDidBeginDragging(dayView: CalendarKit.DayView) {
        print("dayViewDidBeginDragging")
    }
    
    func dayViewDidTransitionCancel(dayView: CalendarKit.DayView) {
        print("dayViewDidTransitionCancel")
    }
    
    func dayView(dayView: CalendarKit.DayView, willMoveTo date: Date) {
        print("willMoveTo")
    }
    
    func dayView(dayView: CalendarKit.DayView, didMoveTo date: Date) {
        print("didMoveTo")
    }
    
    func dayView(dayView: CalendarKit.DayView, didUpdate event: any CalendarKit.EventDescriptor) {
        print("didUpdate")
    }
    
 
    func eventsForDate(_ date: Date) -> [EventDescriptor] {
            return eventsDictionary[date] ?? []
        }
    // Create an event from the user input
    private func createEvent(title: String, date: String, time: String) -> Event? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy h:mm a" // Combine date and time

        let eventDateString = "\(date) \(time)"
        guard let startDate = formatter.date(from: eventDateString) else { return nil }

        let event = Event()
        event.text = title
        event.textColor = .white
        event.color = UIColor(hex: "#F1F8F0") // Example color for the event
        event.dateInterval = DateInterval(start: startDate, duration: 60 * 60) // Example: 1-hour duration
        
        return event
    }
    // Add the event to the events dictionary and update the day view
    private func addEvent(_ event: Event) {
        let eventDate = event.dateInterval.start
        let calendar = Calendar.current
        let dateOnly = calendar.startOfDay(for: eventDate) // Remove time from the date for storage
        
        // Store the event in the dictionary
        if eventsDictionary[dateOnly] != nil {
            eventsDictionary[dateOnly]?.append(event)
        } else {
            eventsDictionary[dateOnly] = [event]
        }
        // Refresh the day view
        dayView.reloadData()
    }
}

// MARK: - FSCalendarDelegate and FSCalendarDataSource
extension ItineraryVC: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // Number of events on a specific date (if needed)
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return date == Date() ? 1 : 0 // Example: 1 event on today's date
    }
    
    // Handle date selection
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("Selected date: \(date)")
    }

    // Customize background color for specific dates
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDateInToday(date) {
            return UIColor(hex: "#F1F8F0") // Background color for today's date
        }
        return nil
    }

    // Customize text color for specific dates
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDateInToday(date) {
            return .app // Text color for today's date
        }
        return nil
    }
}
// MARK: - Popup
extension ItineraryVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    //UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    }
}
