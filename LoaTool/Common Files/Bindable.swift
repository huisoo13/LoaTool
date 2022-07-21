//
//  Bindable.swift
//  Sample
//
//  Created by Trading Taijoo on 2021/05/31.
//

import UIKit

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?) -> ())?
    
    func bind(observer: @escaping (T?) -> ()) {
        self.observer = observer
    }
}

/* Usage
 view.addGestureRecognizer(with: .pan) { sender in
     guard let sender = sender as? UIPanGestureRecognizer else { return }
     // Code..
 }
 */
extension UIView {
    enum GestureRecognizerType {
        case tap
        case longPress
        case swipe
        case pinch
        case pan
        case rotation
        case screenEdgePan
        case unknown
    }
        
    func addGestureRecognizer<T: UIGestureRecognizer>(with type: GestureRecognizerType = .tap, action: @escaping (T?) -> Void) {
        var gesture = UIGestureRecognizer()

        switch type {
        case .tap:
            gesture = TapGestureRecognizer { action(gesture as? T) }
        case .longPress:
            gesture = LongPressGestureRecognizer { action(gesture as? T) }
        case .swipe:
            gesture = SwipeGestureRecognizer { action(gesture as? T) }
        case .pinch:
            gesture = PinchGestureRecognizer { action(gesture as? T) }
        case .pan:
            gesture = PanGestureRecognizer { action(gesture as? T) }
        case .rotation:
            gesture = RotationGestureRecognizer { action(gesture as? T) }
        case .screenEdgePan:
            gesture = ScreenEdgePanGestureRecognizer { action(gesture as? T) }
        default:
            break
        }
        
        self.addGestureRecognizer(gesture)
    }
    
    fileprivate final class TapGestureRecognizer: UITapGestureRecognizer {
        private var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
            super.init(target: nil, action: nil)
            self.addTarget(self, action: #selector(execute))
        }

        @objc private func execute() {
            action()
        }
    }
    
    fileprivate final class LongPressGestureRecognizer: UILongPressGestureRecognizer {
        private var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
            super.init(target: nil, action: nil)
            self.minimumPressDuration = 1.0
            self.addTarget(self, action: #selector(execute))
        }

        @objc private func execute() {
            action()
        }
    }
    
    fileprivate final class SwipeGestureRecognizer: UISwipeGestureRecognizer {
        private var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
            super.init(target: nil, action: nil)
            self.addTarget(self, action: #selector(execute))
        }

        @objc private func execute() {
            action()
        }
    }
    
    fileprivate final class PinchGestureRecognizer: UIPinchGestureRecognizer {
        private var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
            super.init(target: nil, action: nil)
            self.addTarget(self, action: #selector(execute))
        }

        @objc private func execute() {
            action()
        }
    }
    
    fileprivate final class PanGestureRecognizer: UIPanGestureRecognizer {
        private var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
            super.init(target: nil, action: nil)
            self.addTarget(self, action: #selector(execute))
        }

        @objc private func execute() {
            action()
        }
    }
    
    fileprivate final class RotationGestureRecognizer: UIRotationGestureRecognizer {
        private var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
            super.init(target: nil, action: nil)
            self.addTarget(self, action: #selector(execute))
        }

        @objc private func execute() {
            action()
        }
    }
    
    fileprivate final class ScreenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer {
        private var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
            super.init(target: nil, action: nil)
            self.addTarget(self, action: #selector(execute))
        }

        @objc private func execute() {
            action()
        }
    }
}

class BarButtonItem: UIBarButtonItem {
    private var handler: (() -> Void)?

    convenience init(title: String?, style: UIBarButtonItem.Style, handler: (() -> Void)?) {
        self.init(title: title, style: style, target: nil, action: #selector(barButtonItemPressed))
        self.target = self
        self.handler = handler
    }

    convenience init(image: UIImage?, style: UIBarButtonItem.Style, handler: (() -> Void)?) {
        self.init(image: image, style: style, target: nil, action: #selector(barButtonItemPressed))
        self.target = self
        self.handler = handler
    }

    @objc func barButtonItemPressed(sender: UIBarButtonItem) {
        handler?()
    }
}

extension UIBarButtonItem {
    
}
