import Foundation
import SwiftUI

enum AppAppearance: String, CaseIterable, Codable, Identifiable {
    case day = "白天"
    case night = "晚上"

    var id: String { rawValue }
    var colorScheme: ColorScheme { self == .night ? .dark : .light }
}

enum DailyHomeContent: String, CaseIterable, Codable, Identifiable {
    case classicQuote = "经典语句"
    case recommendedSong = "每日推荐歌曲"
    case dailyData = "每日数据"
    case trainingTopic = "热门领域介绍"

    var id: String { rawValue }
}

enum SessionKind: String, CaseIterable, Codable, Identifiable {
    case strengthA = "力量 A"
    case strengthB = "力量 B"
    case runWalk = "跑走耐力"
    case recovery = "恢复日"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .strengthA: "figure.strengthtraining.traditional"
        case .strengthB: "figure.core.training"
        case .runWalk: "figure.run"
        case .recovery: "figure.walk"
        }
    }
    var summary: String {
        switch self {
        case .strengthA: "下肢、推与核心。动作稳定优先。"
        case .strengthB: "臀腿、肩胛稳定与核心。动作稳定优先。"
        case .runWalk: "保持能说完整句子的强度；不适时改快走。"
        case .recovery: "轻松完成即可，不追求训练感。"
        }
    }
}

struct Exercise: Identifiable, Hashable {
    let name: String
    let dose: String
    let purpose: String
    let image: String
    let steps: [String]
    var id: String { name }
    private static let setPattern = try! NSRegularExpression(pattern: #"(\d+)(?:-\d+)?\s*组"#)
    private static let timePattern = try! NSRegularExpression(pattern: #"(\d+)(?:-\d+)?\s*(分钟|分|秒)"#)

    var isPerSide: Bool { dose.contains("每侧") }

    // Only an explicit "组" creates separate completion checks. Per-side work is tracked separately for left and right.
    private var setsPerSide: Int {
        let range = NSRange(dose.startIndex..., in: dose)
        guard let match = Self.setPattern.firstMatch(in: dose, range: range),
              let numberRange = Range(match.range(at: 1), in: dose),
              let count = Int(dose[numberRange]) else { return 1 }
        return count
    }

    var setCount: Int { setsPerSide * (isPerSide ? 2 : 1) }

    func completionLabel(for index: Int) -> String {
        guard isPerSide else { return "第 \(index + 1) 组" }
        let side = index < setsPerSide ? "左侧" : "右侧"
        let set = (index % setsPerSide) + 1
        return setsPerSide == 1 ? side : "\(side)第 \(set) 组"
    }

    var timerSeconds: Int? {
        guard !dose.contains("+"), !dose.contains("轮") else { return nil }
        let range = NSRange(dose.startIndex..., in: dose)
        guard let match = Self.timePattern.firstMatch(in: dose, range: range),
              let amountRange = Range(match.range(at: 1), in: dose),
              let unitRange = Range(match.range(at: 2), in: dose),
              let amount = Int(dose[amountRange]) else { return nil }
        let seconds = dose[unitRange] == "秒" ? amount : amount * 60
        return seconds <= 180 ? seconds : nil
    }
}

let trainingPlans: [SessionKind: [Exercise]] = [
    .strengthA: [
        Exercise(name: "自重深蹲", dose: "3 组 x 10-15 次", purpose: "建立下肢力量，支持体态与日常消耗", image: "bodyweight-squat", steps: ["双脚与髋同宽，脚尖自然微外。", "臀部先向后坐，膝盖沿脚尖方向移动。", "脚掌均匀发力站起，不借反弹。"]),
        Exercise(name: "高位俯卧撑", dose: "3 组 x 8-12 次", purpose: "练胸、手臂与推力，动作稳定优先", image: "incline-pushup", steps: ["双手放在稳定高支撑面，身体成直线。", "肘部向后约 30-45 度，不耸肩。", "出现不稳、锐痛或麻木时停止。"]),
        Exercise(name: "臀桥", dose: "3 组 x 12-20 次", purpose: "激活臀部，改善髋部发力", image: "bridge", steps: ["仰卧屈膝，脚跟在膝盖下方附近。", "脚跟推地、收紧臀部抬髋。", "顶部停一秒，避免靠挺腰抬高。"]),
        Exercise(name: "扶椅后撤箭步蹲", dose: "每侧 2-3 组 x 8-10 次", purpose: "单腿力量与平衡，照顾脚踝稳定", image: "lunge", steps: ["轻扶稳固椅背，后脚向后迈小步。", "垂直下沉，前膝对准第二脚趾。", "脚踝不稳时缩短步幅。"]),
        Exercise(name: "死虫式", dose: "3 组 x 每侧 6-10 次", purpose: "练核心控制，减少腰部代偿", image: "dead-bug", steps: ["仰卧，髋膝 90 度，轻收腹部。", "缓慢伸远对侧手和腿。", "腰背稳定不拱起，范围小也可以。"]),
        Exercise(name: "侧桥", dose: "每侧 2 组 x 15-30 秒", purpose: "强化侧向核心，提升躯干稳定", image: "side-plank", steps: ["前臂在肩正下方。", "抬髋，头肩髋踝尽量成线。", "髋下沉或肩不适时结束。"])
    ],
    .strengthB: [
        Exercise(name: "靠墙静蹲", dose: "3 组 x 35-60 秒", purpose: "锻炼大腿耐力，动作可控不冲击", image: "wall-sit", steps: ["背部贴墙，双脚向前迈出半步到一步。", "下滑到无膝痛的稳定角度。", "全脚掌着地，持续呼吸。"]),
        Exercise(name: "单腿臀桥", dose: "每侧 3 组 x 8-12 次", purpose: "强化单侧臀部与骨盆稳定", image: "single-leg-bridge", steps: ["先摆好双腿臀桥姿势。", "支撑脚跟推地，骨盆保持水平。", "变形时改回双腿臀桥。"]),
        Exercise(name: "高位俯卧撑", dose: "3 组 x 8-12 次", purpose: "练胸、手臂与推力，动作稳定优先", image: "incline-pushup", steps: ["支撑面调到肩部稳定、无痛的高度。", "动作慢而可控。", "出现不稳立即停止。"]),
        Exercise(name: "墙面滑手", dose: "3 组 x 8-12 次", purpose: "改善肩胛控制，温和恢复上肢活动", image: "wall-slide", steps: ["肋骨轻收，肩颈放松。", "双手沿墙上滑至舒适范围。", "下滑时保持肩胛平稳。"]),
        Exercise(name: "俯卧 Y-T 抬臂", dose: "各 2 组 x 6-10 次", purpose: "练上背稳定，辅助肩部保护", image: "prone-yt", steps: ["俯卧，额头轻贴毛巾。", "分别以 Y、T 形小幅抬臂。", "不甩手、不耸肩。"]),
        Exercise(name: "平板支撑", dose: "3 组 x 20-40 秒", purpose: "建立腹部耐力，稳定躯干", image: "forearm-plank", steps: ["前臂在肩正下方。", "收紧臀腹，身体保持长直线。", "姿势变形前结束。"])
    ],
    .runWalk: [
        Exercise(name: "热身快走", dose: "8 分钟", purpose: "升高体温，让脚踝和呼吸进入状态", image: "brisk-walk", steps: ["先用舒适步速开始。", "逐步加快到身体微热。", "脚踝不适则降速。"]),
        Exercise(name: "跑走交替", dose: "跑 2 分钟 + 走 2 分钟，7-8 轮", purpose: "提升耐力与心肺，支持减脂", image: "run-walk", steps: ["完成热身后再开始跑段。", "不冲刺，让走段恢复呼吸。", "脚踝痛、肿或不稳时改全程快走。"]),
        Exercise(name: "小腿拉伸", dose: "每侧 2 组 x 30 秒", purpose: "放松小腿，照顾脚踝活动范围", image: "calf-stretch", steps: ["双手扶墙，后脚跟踩实。", "后膝伸直与微屈各做一轮。", "保持轻微牵拉，不弹震。"])
    ],
    .recovery: [
        Exercise(name: "轻松快走", dose: "20-30 分钟", purpose: "低压力活动，维持消耗并帮助恢复", image: "brisk-walk", steps: ["选择平坦路线。", "以能轻松交谈的步速走。", "脚踝不适就提前结束。"]),
        Exercise(name: "踝关节活动", dose: "每侧 1 分钟", purpose: "保持踝关节灵活，减少僵硬感", image: "ankle-circle", steps: ["坐姿或扶墙站立。", "缓慢画圈并做勾脚、下压。", "刺痛或肿胀时停止。"]),
        Exercise(name: "呼吸放松", dose: "3 分钟", purpose: "降低紧张感，帮助训练后恢复", image: "diaphragmatic-breathing", steps: ["舒适坐或躺，一手放腹部。", "缓慢吸气，呼气稍长。", "不憋气，不刻意用力。"])
    ]
]

let dailyRepair: [Exercise] = [
    Exercise(name: "单脚站立", dose: "每侧 2 组 x 30 秒", purpose: "练脚踝平衡，增强落地稳定", image: "single-leg-stand", steps: ["站在墙边或椅旁。", "支撑脚三点均匀着地。", "摇晃时可轻触墙面。"]),
    Exercise(name: "慢速提踵", dose: "3 组 x 12-20 次", purpose: "强化小腿与踝部控制", image: "slow-calf-raise", steps: ["扶墙站稳，双脚平行。", "抬起脚跟，顶部停一秒。", "用 2-3 秒慢慢放下。"]),
    Exercise(name: "墙面肩胛俯卧撑", dose: "2 组 x 10-15 次", purpose: "唤醒肩胛控制", image: "wall-scapular-push", steps: ["双手撑墙，手臂伸直。", "不屈肘，只让肩胛靠近再推远。", "出现不稳时停止。"]),
    Exercise(name: "墙面滑手", dose: "2 组 x 8-12 次", purpose: "保持肩部活动，改善肩胛配合", image: "wall-slide", steps: ["肩颈放松，肋骨轻收。", "沿墙上滑至舒适范围。", "动作小而慢。"])
]
