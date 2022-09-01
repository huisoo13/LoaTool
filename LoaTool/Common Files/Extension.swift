//
//  Extension.swift
//  Sample
//
//  Created by Trading Taijoo on 2021/06/01.
//

import UIKit
import AVFoundation

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}

extension String {
    func attributed(of searchString: String, key: NSAttributedString.Key, value: Any) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let length = self.count
        var range = NSRange(location: 0, length: length)
        var rangeArray = [NSRange]()
        
        while range.location != NSNotFound {
            range = (attributedString.string as NSString).range(of: searchString, options: .caseInsensitive, range: range)
            rangeArray.append(range)
            
            if range.location != NSNotFound {
                range = NSRange(location: range.location + range.length, length: self.count - (range.location + range.length))
            }
        }
        
        rangeArray.forEach {
            attributedString.addAttribute(key, value: value, range: $0)
        }
        
        return attributedString
    }
    
    func attributed(using pattern: String, key: NSAttributedString.Key, value: Any) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let length = self.count
            let range = NSRange(location: 0, length: length)
            let matches = (regex.matches(in: self, options: [], range: range))

            matches.forEach {
                attributedString.addAttribute(key, value: value, range: $0.range)
            }
        } catch {
            debug(error)
        }
        
        return attributedString
    }

}

extension NSMutableAttributedString {
    func addAttribute(of searchString: String, key: NSAttributedString.Key, value: Any) -> NSMutableAttributedString {
        let length = self.string.count
        var range = NSRange(location: 0, length: length)
        var rangeArray = [NSRange]()
        
        while range.location != NSNotFound {
            range = (self.string as NSString).range(of: searchString, options: .caseInsensitive, range: range)
            rangeArray.append(range)
            
            if range.location != NSNotFound {
                range = NSRange(location: range.location + range.length, length: self.string.count - (range.location + range.length))
            }
        }
        
        rangeArray.forEach {
            self.addAttribute(key, value: value, range: $0)
        }
        
        return self
    }
    
    func addAttribute(using pattern: String, key: NSAttributedString.Key, value: Any) -> NSMutableAttributedString {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let length = self.string.count
            let range = NSRange(location: 0, length: length)
            let matches = (regex.matches(in: self.string, options: [], range: range)) as [NSTextCheckingResult]

            matches.forEach {
                self.addAttribute(key, value: value, range: $0.range)
            }
        } catch {
            debug(error)
        }
        
        return self
    }
}

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstLowercased: String { prefix(1).lowercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}


// Time format
extension CMTime {
    var roundedSeconds: TimeInterval {
        return seconds.rounded()
    }
    
    var hours:  Int { return Int(roundedSeconds / 3600) }
    var minute: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 60)) }
    
    var positionalTime: String {
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%01d:%02d",
                   minute, second)
    }
}


extension UIImage {

    /// This method creates an image of a view
    convenience init?(view: UIView) {

        // Based on https://stackoverflow.com/a/41288197/1118398
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
        }

        if let cgImage = image.cgImage {
            self.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        } else {
            return nil
        }
    }
}

extension Array {
    mutating func append(_ newElements: () -> Element) {
        let element: Element = newElements()
        self.append(element)
    }
}


extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}


extension UILabel {
    func replaceEllipsis(with string: String, highlight: String? = nil, handler: @escaping ()->()) {
        guard let text = self.text else { return }

        lineBreakMode = .byClipping
        
        // STEP 0: Ellipsis가 필요 없는 경우 return
        if numberOfLine(for: text) <= self.numberOfLines {
            return
        }
        
        // STEP 1: text 분리하기
        let stringArray = text.components(separatedBy: "\n")
        
        var numberOfLines: Int = 0
        var index: Int = 0
        
        // STEP 2: 분리한 String마다 UILabel에 대입하여 numberOfLine 값을 구하기
        while !(numberOfLines >= self.numberOfLines) {
            guard let string = stringArray[safe: index] else { break }
            
            let numberOfLine = numberOfLine(for: string)
            
            // STEP 3: 구한 numberOfLine을 더하면서 UILabel의 numberOfLines 값과 같거나 커지는 index 값을 찾기
            numberOfLines += numberOfLine

            if !(numberOfLines >= self.numberOfLines) { index += 1 }
        }

        guard let last = stringArray[safe: index] else { return }
        
        // STEP 4: 원하는 Ellipsis를 마지막에 붙였을때 UILabel의 numberOfLines 값을 넘지 않도록 마지막을 제거
        var result = stringArray[0..<index].joined(separator: "\n") + "\n" + last
        while !(numberOfLine(for: result + string) == self.numberOfLines) {
            result.removeLast()
        }
        
        // STEP 5: 완성된 String 값을 UILabel에 적용
        result += string
        
        self.text = result
        self.sizeToFit()
        
        // STEP 6: 하이라이트 추가
        guard let highlight = highlight else { return }
        
        let attributedString = NSMutableAttributedString(string: result)
        let length = result.count
        var range = NSRange(location: 0, length: length)
        var rangeArray = [NSRange]()
        
        // STEP 6-1: 전체 텍스트에서 해당 단어가 포함된 모든 범위 구하기
        while range.location != NSNotFound {
            range = (attributedString.string as NSString).range(of: highlight, options: .caseInsensitive, range: range)
            rangeArray.append(range)
            
            if range.location != NSNotFound {
                range = NSRange(location: range.location + range.length, length: result.count - (range.location + range.length))
            }
        }
        
        // STEP 6-2: Ellipsis 특성상 텍스트 가장 마지막에 위치하므로 구한 범위 중 가장 마지막 범위를 사용
        guard let range = rangeArray.filter({ $0.location != NSNotFound }).last else { return }
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: range)
        self.attributedText = attributedString
        
        
        // STEP 7: 터치 이벤트 추가
        self.isUserInteractionEnabled = true
        
        let gestureRecognizer = RangeGestureRecognizer(target: self, action: #selector(didTapAttributedTextInLabel(_ :)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.range = range
        gestureRecognizer.function = handler
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func didTapAttributedTextInLabel(_ sender: RangeGestureRecognizer) {
        guard let range = sender.range,
              let function = sender.function else { return }
        if sender.didTapAttributedTextInLabel(self, in: range) {
            function()
        }
    }
    
    fileprivate func numberOfLine(for text: String) -> Int {
        guard let font = self.font, text.count != 0 else { return 0 }
        
        let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = text.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let numberOfLine = Int(ceil(CGFloat(labelSize.height) / font.lineHeight))

        return numberOfLine
    }
}

/// 참고 - https://brunochenchih.medium.com/add-a-tap-gesture-to-a-part-of-a-uilabel-ios-swift-98414bab6ce0
class RangeGestureRecognizer: UITapGestureRecognizer {
    // Stored variables
    var range: NSRange?
    var function: (()->())?
    
    func didTapAttributedTextInLabel(_ label: UILabel, in targetRange: NSRange) -> Bool {
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
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
