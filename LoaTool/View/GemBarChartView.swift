//
//  GemBarChartView.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2021/11/12.
//

import UIKit

class GemBarChartView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }
    
    var values: [Gem]? {
        didSet {
            guard let values = values,
                  let stackView = self.stackView else { return }

            stackView.arrangedSubviews.enumerated().forEach { i, subview in
                guard let view = subview.subviews.last,
                      let label = subview.subviews.first as? UILabel else { return }

                setProgress(view, value: values[safe: i]?.level ?? 0)
                let text = values[safe: i]?.title.replacingOccurrences(of: "[0-9]+레벨 ", with: "", options: .regularExpression) ?? ""
                label.text = "\(text[safe: text.startIndex] ?? " ")"

                view.layer.cornerRadius = 2
            }
        }
    }
        
    private func loadView() {
        let view = Bundle.main.loadNibNamed("GemBarChartView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)

    }
    
    private func setProgress(_ view: UIView, value: Int) {
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let progress = UIView()
        progress.backgroundColor = value >= 7 ? .systemOrange : .systemGray2
        progress.layer.cornerRadius = 2
        
        view.addSubview(progress)
        
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        progress.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        progress.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        progress.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CGFloat(value * 4) / view.bounds.height).isActive = true
        
        let label = UILabel()
        label.text = String(value)
        label.textColor = .label
        label.font = .systemFont(ofSize: 10, weight: .thin)
        
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: progress.topAnchor, constant: -2).isActive = true

        
    }
}
