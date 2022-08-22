//
//  SearchViewModel.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/06.
//

import UIKit

class SearchViewModel {
    var result = Bindable<Character>()
    var error: Parsing.ParsingError?
    
    var timer: Timer?

    func configure(search text: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { (_) in
            IndicatorView.showLoadingView()
            
            Parsing.shared.downloadHTML(text, type: [.stats, .equip, .engrave, .gem, .card]) { data, error in
                self.error = error
                self.result.value = data
                                
                IndicatorView.hideLoadingView()
            }
        })
    }
}
