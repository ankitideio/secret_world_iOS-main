//
//  AnalysisVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 02/01/25.
//

import UIKit
import Charts

class AnalysisVC: UIViewController {
//MARK: - IBOutlet
    @IBOutlet var viewNumberPicker: UIView!
    @IBOutlet var heightVwLineGraph: NSLayoutConstraint!
    @IBOutlet var btnProductAnalysis: UIButton!
    @IBOutlet var viewStoreGraph: BarChartView!
    @IBOutlet var viewProductGraph: LineChartView!
    
    //MARK: - variables
    var arrMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var arrWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var weeklyData = [100, 200, 150, 300, 250, 180, 220]
    var monthlyData = [50, 60, 70, 85, 90, 95, 110, 115, 120, 130, 140, 150]
    var numberPickerData = Array(1...100) // Numbers from 1 to 100
    override func viewDidLoad() {
        super.viewDidLoad()
        setBarChartData(dataPoints: arrWeek, values: weeklyData)
        setupLineChart()
        
    }
    //MARK: - Set Chart Data
    func setBarChartData(dataPoints: [String], values: [Int]) {
        let customRenderer = MyBarChartRenderer(dataProvider: viewStoreGraph,
                                                 animator: viewStoreGraph.chartAnimator,
                                                 viewPortHandler: viewStoreGraph.viewPortHandler)
        // Set the custom renderer
        viewStoreGraph.renderer = customRenderer

        var dataEntries: [BarChartDataEntry] = []
        var barColors: [UIColor] = []

        // Assign different colors to each weekday
        let colors: [UIColor] = [
            UIColor.red, // Monday
            UIColor.orange, // Tuesday
            UIColor.blue, // Wednesday
            UIColor.brown, // Thursday
            UIColor.blue, // Friday
            UIColor.purple, // Saturday
            UIColor.cyan // Sunday
        ]
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
            
            // Assign the color for the corresponding day
            barColors.append(colors[i % colors.count])
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Weekly Data")
        chartDataSet.colors = barColors // Set colors for each bar
        chartDataSet.drawValuesEnabled = true

        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.5
        viewStoreGraph.isUserInteractionEnabled = false
        viewStoreGraph.data = chartData

        // Customize X-Axis
        let xAxis = viewStoreGraph.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        xAxis.granularity = 1
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false

        // Customize Left Y-Axis
        let leftAxis = viewStoreGraph.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = false

        // Disable Right Y-Axis
        viewStoreGraph.rightAxis.enabled = false

        // Customize Chart Appearance
        viewStoreGraph.legend.enabled = false
        viewStoreGraph.animate(yAxisDuration: 1.5)
    }

    
    //MARK: - Setup Line Chart with Gradient Fill
    func setupLineChart() {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<arrWeek.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(weeklyData[i]))
            dataEntries.append(dataEntry)
        }

        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "")
        chartDataSet.colors = [UIColor(hex: "#3E9C35")] // Line color
        chartDataSet.lineWidth = 2.0
        chartDataSet.drawCirclesEnabled = false // No circle at data points
        chartDataSet.mode = LineChartDataSet.Mode.horizontalBezier // Smooth curve
        chartDataSet.drawValuesEnabled = false // Hide data values

        // Gradient fill
        let gradientColors = [UIColor(hex: "#3E9C35").withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: [0.0, 1.0])!
        chartDataSet.fill = LinearGradientFill(gradient: gradient, angle: 90.0)
        chartDataSet.drawFilledEnabled = true

        let chartData = LineChartData(dataSet: chartDataSet)
        viewProductGraph.data = chartData

        // Customize X-Axis
        let xAxis = viewProductGraph.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: arrWeek)
        xAxis.granularity = 1
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = true
        xAxis.gridLineWidth = 0.5
        xAxis.gridColor = UIColor.lightGray

        // Customize Left Y-Axis
        let leftAxis = viewProductGraph.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridLineWidth = 0.5
        leftAxis.gridColor = UIColor.lightGray

        // Disable Right Y-Axis
        viewProductGraph.rightAxis.enabled = false

        // Customize Chart Appearance
        viewProductGraph.legend.enabled = false
        viewProductGraph.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
        viewProductGraph.isUserInteractionEnabled = false
        viewProductGraph.backgroundColor = UIColor.white
    }
    
 @IBAction func actionProductAnalysis(_ sender: UIButton){
            view.endEditing(true)
            let vc = storyboard?.instantiateViewController(withIdentifier: "GigPopOversVC") as! GigPopOversVC
            vc.type = "calender"
            vc.callBack = {[weak self] type,title,id in

            }
            vc.modalPresentationStyle = .popover
            let popOver : UIPopoverPresentationController = vc.popoverPresentationController!
            popOver.sourceView = sender
            popOver.delegate = self
            popOver.permittedArrowDirections = .up
     vc.preferredContentSize = CGSize(width: btnProductAnalysis.frame.size.width, height: 100)
            self.present(vc, animated: false)
        
    }

       
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
// MARK: - Popup
extension AnalysisVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    //UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    }
}

//MARK: - BarChartRenderer
class MyBarChartRenderer: BarChartRenderer {
    override func drawDataSet(context: CGContext, dataSet: BarChartDataSetProtocol, index: Int) {
        guard let barDataProvider = dataProvider else { return }
        let trans = barDataProvider.getTransformer(forAxis: dataSet.axisDependency)
        var barRectBuffer = CGRect()
        
        context.saveGState()
        context.beginTransparencyLayer(auxiliaryInfo: .none)
        
        for i in stride(from: dataSet.entryCount - 1, through: 0, by: -1) {
            guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }
            
            let x = e.x
            let y = e.y
            let left = x - 0.2
            let right = x + 0.2
            let top = y >= 0.0 ? y : 0.0
            let bottom = y <= 0.0 ? y : 0.0
            
            barRectBuffer.origin.x = CGFloat(left)
            barRectBuffer.size.width = CGFloat(right - left)
            barRectBuffer.origin.y = CGFloat(top)
            barRectBuffer.size.height = CGFloat(bottom - top)
            
            trans.rectValueToPixel(&barRectBuffer)
            
            // Calculate the corner radius to make the bars fully rounded
            let cornerRadius = barRectBuffer.size.height / 2.0 // Make it fully rounded

            // Create a fully rounded rect path
            let path = UIBezierPath(roundedRect: barRectBuffer, cornerRadius: cornerRadius)
            
            context.addPath(path.cgPath)
            context.closePath()
            
            context.setFillColor(dataSet.color(atIndex: i).cgColor)
            context.drawPath(using: .fill)
            
            // Draw label on top of the bar
            let label = String(format: "%.0f", e.y)
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.black
            ]
            
            let labelSize = (label as NSString).size(withAttributes: labelAttributes)
            let labelX = barRectBuffer.origin.x + (barRectBuffer.size.width - labelSize.width) / 2
            let labelY = barRectBuffer.origin.y - labelSize.height - 2 // A little padding above the bar

            let labelRect = CGRect(x: labelX, y: labelY, width: labelSize.width, height: labelSize.height)
            label.draw(in: labelRect, withAttributes: labelAttributes)
        }
        
        context.endTransparencyLayer()
        context.restoreGState()
    }
}
