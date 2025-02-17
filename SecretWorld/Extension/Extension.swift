//
//  Extension.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 24/01/24.
//

import Foundation
import UIKit
//MARK: - UIImageView
extension UIImageView {
    static func fromGif(frame: CGRect, resourceName: String) -> UIImageView? {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "gif") else {
            print("Gif does not exist at that path")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let gifData = try? Data(contentsOf: url),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil) else { return nil }
        
        var images = [UIImage]()
        var duration: Double = 0
        
        let imageCount = CGImageSourceGetCount(source)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil),
               let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [CFString: Any],
               let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
               let delayTime = gifProperties[kCGImagePropertyGIFDelayTime] as? Double {
                duration += delayTime
                images.append(UIImage(cgImage: image))
            }
        }
        
        let gifImageView = UIImageView(frame: frame)
        gifImageView.animationImages = images
        gifImageView.animationDuration = duration
        gifImageView.startAnimating()
        return gifImageView
    }
    

}
//MARK: - Textfield
extension UITextField{
    
    //MARK: - Validations
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    func isValidPhone(phone: String) -> Bool {
            let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return phoneTest.evaluate(with: phone)
        }
    @IBInspectable var cornerRadi: CGFloat {
       get {
         return layer.cornerRadius
       }
       set {
         layer.cornerRadius = newValue
         layer.masksToBounds = newValue > 0
       }
     }
    @IBInspectable override var borderWid: CGFloat {
       get {
         return layer.borderWidth
       }
       set {
         layer.borderWidth = newValue
       }
     }
    @IBInspectable override var borderCol: UIColor? {
       get {
         return UIColor(cgColor: layer.borderColor!)
       }
       set {
         layer.borderColor = newValue?.cgColor
       }
     }
    @IBInspectable var paddingLeftCustom: CGFloat {
         get {
             return leftView!.frame.size.width
         }
         set {
             let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
             leftView = paddingView
             leftViewMode = .always
         }
     }

     @IBInspectable var paddingRightCustom: CGFloat {
         get {
             return rightView!.frame.size.width
         }
         set {
             let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
             rightView = paddingView
             rightViewMode = .always
         }
     }
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    func setupRightImage(imageName:String){
      let imageView = UIImageView(frame: CGRect(x: 20, y: 12, width: 15, height: 15))
      imageView.image = UIImage(named: imageName)
      let imageContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 40))
      imageContainerView.addSubview(imageView)
      rightView = imageContainerView
      rightViewMode = .always
      self.tintColor = .lightGray
  }
}

//MARK: - Button

extension UIButton{
    
    @IBInspectable var cornerRadi: CGFloat {
       get {
         return layer.cornerRadius
       }
       set {
         layer.cornerRadius = newValue
         layer.masksToBounds = newValue > 0
       }
     }
    func removeBackgroundImage(for state: UIControl.State) {
           setBackgroundImage(nil, for: state)
       }
    @IBInspectable override var borderWid: CGFloat {
       get {
         return layer.borderWidth
       }
       set {
         layer.borderWidth = newValue
       }
     }
    @IBInspectable override var borderCol: UIColor? {
       get {
         return UIColor(cgColor: layer.borderColor!)
       }
       set {
         layer.borderColor = newValue?.cgColor
       }
     }
       func underline() {
         guard let text = self.titleLabel?.text else { return }
         let attributedString = NSMutableAttributedString(string: text)
         //NSAttributedStringKey.foregroundColor : UIColor.blue
         attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
         attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
         attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
         self.setAttributedTitle(attributedString, for: .normal)
       }
   }
//MARK: - LABLE
extension UILabel{
    @IBInspectable var cornerRadius: CGFloat {
       get {
         return layer.cornerRadius
       }
       set {
         layer.cornerRadius = newValue
         layer.masksToBounds = newValue > 0
       }
     }
    
    
   }

//MARK: - UIView
extension UIView{
    func animateRefreshAndRecenter() {
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                options: [.curveEaseInOut],
                animations: {
                    self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                },
                completion: { _ in
                    UIView.animate(withDuration: 0.15) {
                        self.transform = .identity // Return to original state
                    }
                }
            )
        }
    @IBInspectable var sbothTopcornerRadibotton: CGFloat {
            get {
                return layer.cornerRadius
            }
            set {
                layer.cornerRadius = newValue
                layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            }
        }
    @IBInspectable var sbothBottomCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    @IBInspectable var sRightBottomCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMaxXMaxYCorner]
            clipsToBounds = true  // Ensure the content doesn't exceed the rounded corners
        }
    }
    @IBInspectable var cornerRadiusView: CGFloat {
       get {
         return layer.cornerRadius
       }
       set {
         layer.cornerRadius = newValue
         layer.masksToBounds = newValue > 0
       }
     }
    @IBInspectable var borderWid: CGFloat {
      get {
        return layer.borderWidth
      }
      set {
        layer.borderWidth = newValue
      }
    }
    @IBInspectable var borderCol: UIColor? {
      get {
        return UIColor(cgColor: layer.borderColor!)
      }
      set {
        layer.borderColor = newValue?.cgColor
      }
    }
    
   }

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = .white {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var endColor: UIColor = .black {
        didSet {
            updateGradient()
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    private func updateGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else { return }
               gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
               
               // Set the startPoint and endPoint for a horizontal gradient
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
          gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
}

@IBDesignable
class GradientButton: UIButton {
    
    // Define the colors for the gradient
    @IBInspectable var startColor: UIColor = UIColor.red {
        didSet {
            updateGradient()
        }
    }
    @IBInspectable var endColor: UIColor = UIColor.yellow {
        didSet {
            updateGradient()
        }
    }
    // Create gradient layer
    let gradientLayer = CAGradientLayer()
    
    override func draw(_ rect: CGRect) {
        // Set the gradient frame
        gradientLayer.frame = rect
        
        // Set the colors
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        // Gradient is linear from left to right
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        
        // Add gradient layer into the button
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Round the button corners
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
    }

    func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
  
}



extension UIViewController{
    func applyGradientColor(to label: UILabel, with targetText: String, gradientColors: [Any]) {
          // Create a mutable attributed string
          let attributedString = NSMutableAttributedString(string: label.text ?? "")

          // Find the range of the target text
          let range = (label.text as NSString?)?.range(of: targetText)

          if let range = range {
              // Create a gradient layer
              let gradientLayer = CAGradientLayer()
              gradientLayer.frame = label.bounds
              gradientLayer.colors = gradientColors

           
              UIGraphicsBeginImageContext(gradientLayer.bounds.size)
              gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
              let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
              UIGraphicsEndImageContext()

          
              attributedString.addAttribute(.foregroundColor, value: UIColor(patternImage: gradientImage!), range: range)

              label.attributedText = attributedString
          }
      }
    func getGradientLayer(bounds : CGRect) -> CAGradientLayer{
    let gradient = CAGradientLayer()
    gradient.frame = bounds
    //order of gradient colors
    gradient.colors = [UIColor.red.cgColor,UIColor.blue.cgColor, UIColor.green.cgColor]
    // start and end points
    gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
    gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
    return gradient
    }
    func linearGradientColor(from colors: [UIColor], locations: [CGFloat], size: CGSize) -> UIColor {
        let image = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: size.width, height: size.height)).image { context in
            let cgColors = colors.map { $0.cgColor } as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: cgColors,
                locations: locations
            )!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y:0),
                options:[]
            )
        }
        return UIColor(patternImage: image)
    }
}

class GradientBorderColorView: UIView {
    func setGradientBorderColor(startColor: UIColor, endColor: UIColor, borderWidth: CGFloat) {
        // Create a gradient layer for the border
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        // Create a shape layer to be used as a mask for the gradient
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(rect: bounds).cgPath

        // Set the mask for the gradient layer
        gradientLayer.mask = maskLayer

        // Create a shape layer for the border
        let borderLayer = CAShapeLayer()
        borderLayer.path = UIBezierPath(rect: bounds).cgPath
        borderLayer.strokeColor = UIColor.black.cgColor  // Default border color
        borderLayer.lineWidth = borderWidth
        borderLayer.fillColor = nil

        // Add the border layer to the view's layer
        layer.addSublayer(borderLayer)

        // Add the gradient layer to the view's layer
        layer.addSublayer(gradientLayer)
    }
}

extension UIView{
    func gradiantView(startColor: UIColor, endColor: UIColor) {

        let button: UIButton = UIButton(frame: self.bounds)
       
        let gradient = CAGradientLayer()
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
        self.mask = button

    }
    func gradientButton(_ buttonText: String, startColor: UIColor, endColor: UIColor, textSize: CGFloat, fontFamily: String) {

        let button: UIButton = UIButton(frame: self.bounds)
        button.setTitle(buttonText, for: .normal)
        button.titleLabel?.font = UIFont(name: fontFamily, size: textSize) // Set font size and family

        let gradient = CAGradientLayer()
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
        self.mask = button

        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1.0
    }
 
    func addTopShadow(shadowColor : UIColor, shadowOpacity : Float,shadowRadius : Float,offset:CGSize){
          self.layer.shadowColor = shadowColor.cgColor
          self.layer.shadowOffset = offset
          self.layer.shadowOpacity = shadowOpacity
          self.layer.shadowRadius = CGFloat(shadowRadius)
          self.clipsToBounds = false
      }
    @discardableResult
       func addLineDashedStroke(pattern: [NSNumber]?, radius: CGFloat, color: CGColor) -> CALayer {
           let borderLayer = CAShapeLayer()

           borderLayer.strokeColor = color
           borderLayer.lineWidth = 2
           borderLayer.lineDashPattern = pattern
           borderLayer.frame = bounds
           borderLayer.fillColor = nil
           borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath

           layer.addSublayer(borderLayer)
           return borderLayer
       }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
      
}

extension CALayer {
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


//MARK: - UISegmentedControl
extension UISegmentedControl{
    func removeBorder(){
        let backgroundImage = UIImage.getColoredRectImageWith(color: UIColor.white.cgColor, andSize: self.bounds.size)
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)

        let deviderImage = UIImage.getColoredRectImageWith(color: UIColor.white.cgColor, andSize: CGSize(width: 1.0, height: self.bounds.size.height))
        self.setDividerImage(deviderImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
    }

    func addUnderlineForSelectedSegment(){
        removeBorder()
        let underlineWidth: CGFloat = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = 4.0
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = self.bounds.size.height - 2.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.backgroundColor = UIColor.app
        underline.tag = 1
        self.addSubview(underline)
    }

    func changeUnderlinePosition(){
        guard let underline = self.viewWithTag(1) else {return}
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)
        UIView.animate(withDuration: 0.1, animations: {
            underline.frame.origin.x = underlineFinalXPosition
        })
    }
}

extension UIImage{

    class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
}


//MARK: - Textfield MaxLenth
private var kAssociationKeyMaxLength: Int = 0
extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        
        selectedTextRange = selection
    }
}
class CustomSlide: UISlider {

     @IBInspectable var trackHeight: CGFloat = 10

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
         //set your bounds here
         return CGRect(origin: bounds.origin, size: CGSizeMake(bounds.width, trackHeight))



       }
}
class RectangularDashedView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0
    
    var dashBorder: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }
}
extension UITextField {
    func setInputViewDatePickerAccount(target: Any, selector: Selector, isSelectType: String) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        
        switch isSelectType {
        case "day":
            datePicker.datePickerMode = .date
            datePicker.maximumDate = Date()
        case "time":
            datePicker.datePickerMode = .time
            datePicker.locale = Locale(identifier: "en_US_POSIX")
        case "startEndDate":
            datePicker.datePickerMode = .date
            datePicker.minimumDate = Date()
        case "startEndTime":
            datePicker.datePickerMode = .time
        case "startTime":
            datePicker.datePickerMode = .time
        case "endTime":
            datePicker.datePickerMode = .time
        case "EndDateTime":
            datePicker.datePickerMode = .date
            datePicker.minimumDate = Date()
        default:
            break
        }

        // iOS 14 and above
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }

        self.inputView = datePicker
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel2))
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }

    @objc func tapCancel2() {
        self.resignFirstResponder()
    }
    func setInputViewDatePickerPop(target: Any, selector: Selector, isSelectType: String) {
        
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        
        // Configure the date picker based on the isSelectType parameter
        switch isSelectType {
        case "day":
            datePicker.datePickerMode = .date
            datePicker.maximumDate = Date()
        case "time":
            datePicker.datePickerMode = .time
            datePicker.locale = Locale(identifier: "en_US_POSIX")
        case "startEndDate":
            datePicker.datePickerMode = .date
            datePicker.minimumDate = Date()
        case "startEndTime":
            datePicker.datePickerMode = .time
        case "startTime":
            datePicker.datePickerMode = .time
        case "endTime":
            datePicker.datePickerMode = .time
        case "EndDateTime":
            datePicker.datePickerMode = .date
            datePicker.minimumDate = Date()
        default:
            break
        }

        // iOS 14 and above
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }

        // Add target-action pair to detect value change
        datePicker.addTarget(target, action: selector, for: .valueChanged)
        
        self.inputView = datePicker
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel))
        let done = UIBarButtonItem(title: "Done", style: .plain, target: nil, action:  #selector(tapDone))
        toolBar.setItems([cancel, flexible, done], animated: false)
        self.inputAccessoryView = toolBar
        
    }
    @objc func tapDone() {
        if let datePicker = self.inputView as? UIDatePicker {
            let formatter = DateFormatter()
            
            // Updated date format
            if datePicker.datePickerMode == .date {
                formatter.dateFormat = "dd-MM-yyyy"
            } else if datePicker.datePickerMode == .time {
                formatter.dateStyle = .none
                formatter.timeStyle = .short
            } else {
                formatter.dateFormat = "dd-MM-yyyy"
                formatter.timeStyle = .short
            }
            self.text = formatter.string(from: datePicker.date)
        }
        self.resignFirstResponder()
    }
    @objc func tapCancel() {
        print("cancel")
        self.resignFirstResponder()
    }
    func setInputViewDatePickerEndTime(target: Any, selector: Selector, isSelectType: String) {
        
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        
        // Configure the date picker based on the isSelectType parameter
        switch isSelectType {
        case "endTime":
            datePicker.datePickerMode = .time
        default:
            break
        }

        // iOS 14 and above
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }

        // Add target-action pair to detect value change
        datePicker.addTarget(target, action: selector, for: .valueChanged)
        
        self.inputView = datePicker
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel11))
        let done = UIBarButtonItem(title: "Done", style: .plain, target: nil, action:  #selector(tapDone11))
        toolBar.setItems([cancel, flexible, done], animated: false)
        self.inputAccessoryView = toolBar
        
    }
    @objc func tapDone11() {
        if let datePicker = self.inputView as? UIDatePicker {
            let formatter = DateFormatter()
            
             if datePicker.datePickerMode == .time {
                formatter.dateStyle = .none
                formatter.timeStyle = .short
            } 
            self.text = formatter.string(from: datePicker.date)
        }
        self.resignFirstResponder()
    }
    @objc func tapCancel11() {
        print("cancel")
        self.resignFirstResponder()
    }
}

extension UILabel {

    func addTrailing(with trailingText: String, moreText: String, lessText: String, moreTextFont: UIFont, moreTextColor: UIColor, lessTextFont: UIFont, lessTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        let readLessText: String = trailingText + lessText

        let lengthForVisibleString: Int = self.visibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        let readLessAttributed = NSMutableAttributedString(string: lessText, attributes: [NSAttributedString.Key.font: lessTextFont, NSAttributedString.Key.foregroundColor: lessTextColor])
        
        answerAttributed.append(self.isTruncated ? readLessAttributed : readMoreAttributed)
        self.attributedText = answerAttributed
    }

    var isTruncated: Bool {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)

        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes)
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)

        return boundingRect.size.height > labelHeight
    }

    var visibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)

        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes)
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)

        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}
extension Date {
    func timeAgo() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        return String(format: formatter.string(from: self, to: Date()) ?? "", locale: .current)
    }
    
}
extension String {
    func timeAgoSinceDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: self) {
            let timeDifference = Date().timeIntervalSince(date)
                return date.timeAgo()
        } else {
            return "Unknown"
        }
    }
}

enum TrailingContent {
    case readmore
    case readless

    var text: String {
        switch self {
        case .readmore: return " ...Read More"
        case .readless: return " ...Read Less"
        }
    }
}

extension UILabel {

    private var minimumLines: Int { return 4 }
    private var highlightColor: UIColor { return UIColor(hex: "#3E9C35") }

    private var attributes: [NSAttributedString.Key: Any] {
        return [.font: UIFont(name: "Nunito-Regular", size: 15) ?? .systemFont(ofSize: 15)]
    }
    
    public func requiredHeight(for text: String) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = minimumLines
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
      }

    func highlight(_ text: String, color: UIColor) {
        guard let labelText = self.text else { return }
        let range = (labelText as NSString).range(of: text)

        let mutableAttributedString = NSMutableAttributedString.init(string: labelText)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        self.attributedText = mutableAttributedString
    }

    func appendReadmore(after text: String, trailingContent: TrailingContent) {
        self.numberOfLines = minimumLines
        let fourLineText = "\n\n\n"
        let fourlineHeight = requiredHeight(for: fourLineText)
        let sentenceText = NSString(string: text)
        let sentenceRange = NSRange(location: 0, length: sentenceText.length)
        var truncatedSentence: NSString = sentenceText
        var endIndex: Int = sentenceRange.upperBound
        let size: CGSize = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        while truncatedSentence.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height >= fourlineHeight {
            if endIndex == 0 {
                break
            }
            endIndex -= 1

            truncatedSentence = NSString(string: sentenceText.substring(with: NSRange(location: 0, length: endIndex)))
            truncatedSentence = (String(truncatedSentence) + trailingContent.text) as NSString

        }
        self.text = truncatedSentence as String
        self.highlight(trailingContent.text, color: highlightColor)
    }

    func appendReadLess(after text: String, trailingContent: TrailingContent) {
        self.numberOfLines = 0
        self.text = text + trailingContent.text
        self.highlight(trailingContent.text, color: highlightColor)
    }
}

extension UITapGestureRecognizer {

    func didTap(label: UILabel, inRange targetRange: NSRange) -> Bool {
        
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }

}

