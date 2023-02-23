//
//  String.swift
//  SwiftSoupSamle
//
//  Created by Trading Taijoo on 2021/11/05.
//

import UIKit

extension String {
    static func job() -> [String] {
        return ["워로드", "디스트로이어", "버서커", "홀리나이트", "슬레이어",
                "데빌헌터", "블래스터", "호크아이", "스카우터", "건슬링어",
                "배틀마스터", "인파이터", "기공사", "창술사", "스트라이커",
                "바드", "서머너", "아르카나", "소서리스",
                "리퍼", "블레이드", "데모닉",
                "도화가", "기상술사"]
    }
    
    static func jobEngrave() -> [String] {
        return ["분노의 망치",
                "중력 수련",
                "고독한 기사",
                "전투 태세",
                "광기",
                "광전사의 비기",
                "오의 강화",
                "초심",
                "극의: 체술",
                "충격 단련",
                "세맥타통",
                "역천지체",
                "강화 무기",
                "핸드거너",
                "연속 포격",
                "화력 강화",
                "두 번째 동료",
                "죽음의 습격",
                "진실된 용맹",
                "절실한 구원",
                "넘치는 교감",
                "상급 소환사",
                "황제의 칙령",
                "황후의 은총",
                "절정",
                "절제",
                "버스트",
                "잔재된 기운",
                "멈출 수 없는 충동",
                "완벽한 억제",
                "심판자",
                "축복의 오라",
                "아르데타인의 기술",
                "진화의 유산",
                "갈증",
                "달의 소리",
                "사냥의 시간",
                "피스메이커",
                "일격필살",
                "오의난무",
                "점화",
                "환류",
                "만개",
                "회귀",
                "이슬비",
                "질풍노도",
                "처단자",
                "포식자"]
    }
    
    static func engraving() -> [String] {
        return ["분노의 망치",
                "중력 수련",
                "고독한 기사",
                "전투 태세",
                "광기",
                "광전사의 비기",
                "오의 강화",
                "초심",
                "극의: 체술",
                "충격 단련",
                "세맥타통",
                "역천지체",
                "강화 무기",
                "핸드거너",
                "연속 포격",
                "화력 강화",
                "두 번째 동료",
                "죽음의 습격",
                "진실된 용맹",
                "절실한 구원",
                "넘치는 교감",
                "상급 소환사",
                "황제의 칙령",
                "황후의 은총",
                "절정",
                "절제",
                "버스트",
                "잔재된 기운",
                "멈출 수 없는 충동",
                "완벽한 억제",
                "심판자",
                "축복의 오라",
                "아르데타인의 기술",
                "진화의 유산",
                "갈증",
                "달의 소리",
                "사냥의 시간",
                "피스메이커",
                "일격필살",
                "오의난무",
                "점화",
                "환류",
                "만개",
                "회귀",
                "이슬비",
                "질풍노도",
                "처단자",
                "포식자",
                "-",
                "각성",
                "강령술",
                "강화 방패",
                "결투의 대가",
                "구슬동자",
                "굳은 의지",
                "급소 타격",
                "기습의 대가",
                "긴급 구조",
                "달인의 저력",
                "돌격대장",
                "마나 효율 증가",
                "마나의 흐름",
                "바리케이드",
                "번개의 분노",
                "부러진 뼈",
                "분쇄의 주먹",
                "불굴",
                "선수필승",
                "속전속결",
                "슈퍼 차지",
                "승부사",
                "시선 집중",
                "실드 관통",
                "아드레날린",
                "안정된 상태",
                "약자 무시",
                "에테르 포식자",
                "여신의 가호",
                "예리한 둔기",
                "원한",
                "위기 모면",
                "저주받은 인형",
                "전문의",
                "정기 흡수",
                "정밀 단도",
                "중갑 착용",
                "질량 증가",
                "최대 마나 증가",
                "추진력",
                "타격의 대가",
                "탈출의 명수",
                "폭발물 전문가"]
    }
    
    static func engrave(_ isPenalty: Bool) -> [String] {
        let titles = ["[디스트로이어]\n분노의 망치",
                      "[디스트로이어]\n중력 수련",
                      "[워로드]\n고독한 기사",
                      "[워로드]\n전투 태세",
                      "[버서커]\n광기",
                      "[버서커]\n광전사의 비기",
                      "[배틀마스터]\n오의 강화",
                      "[배틀마스터]\n초심",
                      "[인파이터]\n극의: 체술",
                      "[인파이터]\n충격 단련",
                      "[기공사]\n세맥타통",
                      "[기공사]\n역천지체",
                      "[데빌헌터]\n강화 무기",
                      "[데빌헌터]\n핸드거너",
                      "[블래스터]\n연속 포격",
                      "[블래스터]\n화력 강화",
                      "[호크아이]\n두 번째 동료",
                      "[호크아이]\n죽음의 습격",
                      "[바드]\n진실된 용맹",
                      "[바드]\n절실한 구원",
                      "[서머너]\n넘치는 교감",
                      "[서머너]\n상급 소환사",
                      "[아르카나]\n황제의 칙령",
                      "[아르카나]\n황후의 은총",
                      "[창술사]\n절정",
                      "[창술사]\n절제",
                      "[블레이드]\n버스트",
                      "[블레이드]\n잔재된 기운",
                      "[데모닉]\n멈출 수 없는 충동",
                      "[데모닉]\n완벽한 억제",
                      "[홀리나이트]\n심판자",
                      "[홀리나이트]\n축복의 오라",
                      "[스카우터]\n아르데타인의 기술",
                      "[스카우터]\n진화의 유산",
                      "[리퍼]\n갈증",
                      "[리퍼]\n달의 소리",
                      "[건슬링어]\n사냥의 시간",
                      "[건슬링어]\n피스메이커",
                      "[스트라이커]\n일격필살",
                      "[스트라이커]\n오의난무",
                      "[소서리스]\n점화",
                      "[소서리스]\n환류",
                      "[도화가]\n만개",
                      "[도화가]\n회귀",
                      "[기상술사]\n이슬비",
                      "[기상술사]\n질풍노도",
                      "[슬레이어]\n처단자",
                      "[슬레이어]\n포식자",
                      "-",
                      "각성",
                      "강령술",
                      "강화 방패",
                      "결투의 대가",
                      "구슬동자",
                      "굳은 의지",
                      "급소 타격",
                      "기습의 대가",
                      "긴급 구조",
                      "달인의 저력",
                      "돌격대장",
                      "마나 효율 증가",
                      "마나의 흐름",
                      "바리케이드",
                      "번개의 분노",
                      "부러진 뼈",
                      "분쇄의 주먹",
                      "불굴",
                      "선수필승",
                      "속전속결",
                      "슈퍼 차지",
                      "승부사",
                      "시선 집중",
                      "실드 관통",
                      "아드레날린",
                      "안정된 상태",
                      "약자 무시",
                      "에테르 포식자",
                      "여신의 가호",
                      "예리한 둔기",
                      "원한",
                      "위기 모면",
                      "저주받은 인형",
                      "전문의",
                      "정기 흡수",
                      "정밀 단도",
                      "중갑 착용",
                      "질량 증가",
                      "최대 마나 증가",
                      "추진력",
                      "타격의 대가",
                      "탈출의 명수",
                      "폭발물 전문가"]
        
        let penalty = ["-",
                       "공격력 감소",
                       "방어력 감소",
                       "이동속도 감소",
                       "공격속도 감소"]

        return isPenalty ? penalty : titles
    }
    
    func getSymbol() -> UIImage {
        switch self {
        case "원정대":
            return UIImage(systemName: "house.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)) ?? UIImage()
        case "워로드":
            return UIImage(named: "job.warlord") ?? UIImage()
        case "디스트로이어":
            return UIImage(named: "job.destroyer") ?? UIImage()
        case "버서커":
            return UIImage(named: "job.berserker") ?? UIImage()
        case "홀리나이트":
            return UIImage(named: "job.holyknight") ?? UIImage()
        case "데빌헌터":
            return UIImage(named: "job.devilhunter") ?? UIImage()
        case "블래스터":
            return UIImage(named: "job.blaster") ?? UIImage()
        case "호크아이":
            return UIImage(named: "job.hawkeye") ?? UIImage()
        case "스카우터":
            return UIImage(named: "job.scouter") ?? UIImage()
        case "건슬링어":
            return UIImage(named: "job.gunslinger") ?? UIImage()
        case "배틀마스터":
            return UIImage(named: "job.battlemaster") ?? UIImage()
        case "인파이터":
            return UIImage(named: "job.infighter") ?? UIImage()
        case "기공사":
            return UIImage(named: "job.soulmaster") ?? UIImage()
        case "창술사":
            return UIImage(named: "job.lancemaster") ?? UIImage()
        case "스트라이커":
            return UIImage(named: "job.striker") ?? UIImage()
        case "바드":
            return UIImage(named: "job.bard") ?? UIImage()
        case "서머너":
            return UIImage(named: "job.summoner") ?? UIImage()
        case "아르카나":
            return UIImage(named: "job.arcana") ?? UIImage()
        case "소서리스":
            return UIImage(named: "job.sorceress") ?? UIImage()
        case "리퍼":
            return UIImage(named: "job.reaper") ?? UIImage()
        case "블레이드":
            return UIImage(named: "job.blade") ?? UIImage()
        case "데모닉":
            return UIImage(named: "job.demonic") ?? UIImage()
        case "도화가":
            return UIImage(named: "job.artist") ?? UIImage()
        case "기상술사":
            return UIImage(named: "job.aeromancer") ?? UIImage()
        case "슬레이어":
            return UIImage(named: "job.slayer") ?? UIImage()
        case "전사(남)":
            return UIImage(named: "job.warrior.male") ?? UIImage()
        case "전사(여)":
            return UIImage(named: "job.warrior.female") ?? UIImage()
        case "무도가(남)":
            return UIImage(named: "job.martialArtist.male") ?? UIImage()
        case "무도가(여)":
            return UIImage(named: "job.martialArtist.female") ?? UIImage()
        case "헌터(남)":
            return UIImage(named: "job.gunner.male") ?? UIImage()
        case "헌터(여)":
            return UIImage(named: "job.gunner.female") ?? UIImage()
        case "마법사":
            return UIImage(named: "job.mage.female") ?? UIImage()
        case "암살자":
            return UIImage(named: "job.assassin.female") ?? UIImage()
        case "스페셜리스트":
            return UIImage(named: "job.specialist.female") ?? UIImage()
        default:
            return UIImage(systemName: "questionmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .ultraLight)) ?? UIImage()
        }
    }
    
    func getContentIcon() -> UIImage {
        let image = UIImage(named: "content.icon.\(self)") ?? UIImage()
        
        return image
    }
    
    func containOfSet() -> Bool {
        let set = ["갈망", "사멸", "배신", "파괴", "매혹", "환각", "구원", "지배", "악몽"]
        
        return set.contains(self)
    }
}
