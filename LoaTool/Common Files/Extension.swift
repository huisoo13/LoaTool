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
