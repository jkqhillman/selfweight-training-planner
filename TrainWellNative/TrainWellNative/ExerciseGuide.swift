import SwiftUI

struct ExerciseGuide: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Image(exercise.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 320)
                        .frame(maxWidth: .infinity)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                    Text(exercise.dose).font(.subheadline).foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(exercise.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top) { Text("\(index + 1)").font(.caption.bold()).frame(width: 22, height: 22).background(.mint, in: Circle()); Text(step) }
                        }
                    }
                    Link("在百度百科查看词条", destination: baikeURL(for: exercise.name))
                        .font(.subheadline.bold())
                    Text("图片已随 App 打包，可离线查看。训练中如有不稳、锐痛、麻木或肿胀，请停止该动作。")
                        .font(.footnote).foregroundStyle(.secondary)
                }.padding()
            }
            .navigationTitle(exercise.name)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } }
        }
    }

    private func baikeURL(for name: String) -> URL {
        let term: String
        switch name {
        case "高位俯卧撑": term = "俯卧撑"
        case "扶椅后撤箭步蹲": term = "箭步蹲"
        case "单腿臀桥": term = "臀桥"
        case "慢速提踵": term = "提踵"
        case "踝关节活动": term = "踝关节"
        case "热身快走", "轻松快走": term = "快走"
        case "跑走交替": term = "跑步"
        default: term = name
        }
        return URL(string: "https://baike.baidu.com/item/\(term.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? term)")!
    }
}
