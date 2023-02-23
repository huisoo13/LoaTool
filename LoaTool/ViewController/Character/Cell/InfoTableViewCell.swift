//
//  InfoTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/29.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var masterImageView: UIImageView!
    @IBOutlet weak var guildLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var expeditionLabel: UILabel!
    @IBOutlet weak var strongholdLabel: UILabel!
    @IBOutlet weak var combatLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    
    @IBOutlet weak var pointView: UIView!
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var healthLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var engraveLabel: UILabel!
    @IBOutlet weak var cardLabel: UILabel!
    
    @IBOutlet weak var jobImageView: UIImageView!
    
    var isSelectedItem: Bool = false
    var data: Character? {
        didSet {
            guard let data = data,
                  let info = data.info,
                  let stats = data.stats,
                  let engrave = data.engrave else {
                return
            }

            nameLabel.text = info.name.components(separatedBy: " ").last
            masterImageView.isHidden = !(info.isMaster)
            guildLabel.text = info.guild.replacingOccurrences(of: "-", with: "")
            serverLabel.text = info.server
            expeditionLabel.text = "Lv.\(info.expedition)"
            strongholdLabel.text = info.town
            combatLabel.text = info.name.components(separatedBy: " ").first
            itemLabel.text = "Lv.\(info.level)"
            
            attackLabel.text = "\(stats.attack)"
            healthLabel.text = "\(stats.health)"
            
            statsLabel.text = convertStatsToString(stats)
            engraveLabel.text = convertEngraveToString(engrave)
            cardLabel.text = convertCardToString(data.card.map({ $0 }))
            
            jobImageView.image = info.job.getSymbol()
            jobImageView.tintColor = .label
            
            pointView.layer.cornerRadius = 4
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func convertStatsToString(_ data: Stats) -> String {
        let stats = ["치명": data.critical,
                     "제압": data.domination,
                     "인내": data.endurance,
                     "숙련": data.expertise,
                     "특화": data.specialization,
                     "신속": data.swiftness
        ].filter({ $0.value >= 100 }).sorted(by: { $0.value > $1.value })
        

        var string = ""
        stats.forEach { (key: String, value: Int) in
            string += !isSelectedItem ? "\(key)-" : "\(value)-"
        }
        
        return String(string.dropLast())
    }
    
    fileprivate func convertEngraveToString(_ data: Engrave) -> String {
        var string = ""
        data.effect.components(separatedBy: "\n").forEach { engrave in
            guard let key = engrave.components(separatedBy: " Lv. ").first,
                  let value = Int(engrave.components(separatedBy: " Lv. ").last ?? "0") else { return }
            
            let isPenalty = String.engrave(true).contains(key)
            
            string += !isSelectedItem ? String(!isPenalty ? value : -value) : (!isPenalty ? String(key[key.startIndex]) : "-" + String(key[key.startIndex]))
        }
        
        return string
    }
    
    fileprivate func convertCardToString(_ data: [Card]) -> String {
        let title = data.map { card in
            card.title.replacingOccurrences(of: " [0-9]+세트", with: "_", options: .regularExpression)
            .replacingOccurrences(of: "각성합계", with: "", options: .regularExpression)
            .replacingOccurrences(of: "_ ", with: "", options: .regularExpression)
            .replacingOccurrences(of: "_", with: "", options: .regularExpression)
        }
        
        let card = data.map { card in
            return card.title.replacingOccurrences(of: " [0-9]+세트", with: "_", options: .regularExpression).components(separatedBy: "_").first ?? ""
        }

        var string = ""
        Set(card).sorted(by: { $0 < $1 }).forEach { card in
            if title.contains(card) {
                guard let data = title.filter({ $0.contains(card)}).sorted(by: { ($0.count, $0) < ($1.count, $1) }).last else { return }
                string += "\(data)\n"
            }
        }
        
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
