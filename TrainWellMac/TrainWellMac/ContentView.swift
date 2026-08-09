import SwiftUI
import Combine
#if canImport(PhotosUI)
import PhotosUI
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

struct ContentView: View {
    @EnvironmentObject private var store: TrainingStore
    @State private var selectedExercise: Exercise?
    @State private var month = Date()
    @State private var showSettings = false
    @State private var showCompletionToast = false
    @State private var completionPulse = false
    @State private var showResetConfirmation = false
    @State private var phoneTab: PhoneTab = .home

    private enum PhoneTab: Hashable {
        case home, training, repair, records, settings
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppPhotoBackground(isVisible: rootBackgroundShouldShow)
                appContent
            }
            .navigationTitle("")
            .sheet(item: $selectedExercise) { ExerciseGuide(exercise: $0) }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .confirmationDialog("重置今日训练？", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("重置今日训练", role: .destructive) { store.resetToday() }
            } message: {
                Text("将清除今天所有动作勾选和今日完成记录，历史训练记录不会受影响。")
            }
            .task { await store.scheduleReminder() }
            .overlay(alignment: .top) {
                if showCompletionToast {
                    Label("今日训练已记录", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.green, in: Capsule())
                        .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
                        .padding(.top, 10)
                        .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale))
                }
            }
        }
        .preferredColorScheme(store.appearance.colorScheme)
    }

    private var rootBackgroundShouldShow: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }

    @ViewBuilder
    private var appContent: some View {
        #if os(macOS)
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                dashboard
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        #else
        TabView(selection: $phoneTab) {
            phonePage(title: "今天训练") {
                todayPlan
            }
            .tabItem { Label("训练", systemImage: "figure.strengthtraining.traditional") }
            .tag(PhoneTab.training)

            phonePage(title: "每日修复") {
                repair
            }
            .tabItem { Label("修复", systemImage: "figure.flexibility") }
            .tag(PhoneTab.repair)

            phonePage(isHome: true) {
                header
                homeSession
                dailyLine
                readiness
            }
            .tabItem { Label("主页", systemImage: "house.fill") }
            .tag(PhoneTab.home)

            phonePage(title: "训练记录") {
                calendar
            }
            .tabItem { Label("记录", systemImage: "calendar") }
            .tag(PhoneTab.records)

            phonePage(title: "设置") {
                settingsHub
            }
            .tabItem { Label("设置", systemImage: "gearshape.fill") }
            .tag(PhoneTab.settings)
        }
        .tint(.teal)
        .background(.clear)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }

    #if !os(macOS)
    private func phonePage<Content: View>(isHome: Bool = false, title: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        ZStack {
            AppPhotoBackground(isVisible: store.backgroundAppliesToAllPages || isHome)
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    if let title {
                        Text(title)
                            .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            .padding(.bottom, 2)
                    }
                    content()
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 46)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(.clear)
        }
    }

    private var homeSession: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日训练")
                .font(.caption.weight(.heavy))
                .foregroundStyle(.teal)
            Text(store.currentSession.rawValue)
                .font(.title2.weight(.bold))
            Text(store.currentSession.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("进入训练") { phoneTab = .training }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppPalette.surface(isNight: store.appearance == .night, opacity: 0.84), in: RoundedRectangle(cornerRadius: 16))
        .overlay { RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.66), lineWidth: 1) }
    }

    private var dailyLine: some View {
        switch store.dailyHomeContent {
        case .classicQuote:
            let item = classicQuotes[dayIndex % classicQuotes.count]
            return dailyCard(title: "每日一句", primary: item.english, secondary: "\(item.quote)\n\(item.source)", primarySingleLine: true)
        case .recommendedSong:
            let item = dailySongs[dayIndex % dailySongs.count]
            return dailyCard(title: "每日推荐歌曲", primary: item.title, secondary: "(item.artist) · (item.note)")
        case .dailyData:
            return dailyCard(title: "每日数据", primary: "本周已完成 \(weeklyCompletedCount) 次训练", secondary: "今天安排：(store.currentSession.rawValue)。稳定完成比临时加量更重要。")
        case .trainingTopic:
            let item = trainingTopics[dayIndex % trainingTopics.count]
            return dailyCard(title: "训练热门话题", primary: item.title, secondary: item.detail)
        }
    }

    private func dailyCard(title: String, primary: String, secondary: String, primarySingleLine: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.teal)
            Text(primary)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(primarySingleLine ? 1 : nil)
                .minimumScaleFactor(primarySingleLine ? 0.72 : 1)
                .layoutPriority(primarySingleLine ? 1 : 0)
            Text(secondary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, primarySingleLine ? 12 : 18)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppPalette.surface(isNight: store.appearance == .night, opacity: 0.82), in: RoundedRectangle(cornerRadius: 16))
        .overlay { RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.62), lineWidth: 1) }
    }

    private var dayIndex: Int {
        ((Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1) - 1) % 7
    }

    private var weeklyCompletedCount: Int {
        guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: .now) else { return 0 }
        return store.completed.keys.filter { interval.contains($0) }.count
    }

    private var classicQuotes: [(quote: String, english: String, source: String)] {
        [
            ("天行健，君子以自强不息。", "As heaven moves with vigor, a person of character strives without cease.", "《周易》"),
            ("不积跬步，无以至千里。", "Without accumulating small steps, one cannot reach a thousand miles.", "《荀子·劝学》"),
            ("胜人者有力，自胜者强。", "To conquer oneself is true strength.", "《道德经》第三十三章"),
            ("合抱之木，生于毫末。", "A tree that fills the arms grows from a tiny shoot.", "《道德经》第六十四章"),
            ("知之者不如好之者，好之者不如乐之者。", "Knowing is not as good as loving, and loving is not as good as taking joy in it.", "《论语·雍也》"),
            ("吾日三省吾身。", "Each day I examine myself in three ways.", "《论语·学而》"),
            ("士不可以不弘毅，任重而道远。", "A person of purpose must be strong and resolute, for the burden is heavy and the road is long.", "《论语·泰伯》")
        ]
    }

    private var dailySongs: [(title: String, artist: String, note: String)] {
        [
            ("Here Comes the Sun", "The Beatles", "适合恢复日或轻松快走的明亮节奏"),
            ("The Nights", "Avicii", "适合跑走训练，保持轻快步频"),
            ("Eye of the Tiger", "Survivor", "适合力量训练前，把注意力收回动作"),
            ("Hall of Fame", "The Script feat. will.i.am", "适合完成计划前的稳定推进"),
            ("The Climb", "Miley Cyrus", "适合低状态日，提醒自己不必冲刺"),
            ("Don't Stop Me Now", "Queen", "适合状态好时热身，不替代热身节奏"),
            ("Beautiful Day", "U2", "适合户外轻松走，保持能交谈的强度")
        ]
    }

    private var trainingTopics: [(title: String, detail: String)] {
        [
            ("蛋白质与恢复", "每餐有稳定蛋白质来源，比偶尔大量补充更容易坚持。"),
            ("跑走训练", "跑段不需要冲刺。走段能把呼吸和步态带回可控范围。"),
            ("渐进训练", "一次只提高一个变量，例如次数或组数，不同时加跑量与力量量。"),
            ("睡眠与表现", "睡眠不足时优先缩短训练或改恢复日，不需要补练。"),
            ("核心训练", "核心的重点是控制躯干，不是把每组都练到腹部酸痛。"),
            ("脚踝稳定", "单脚站立与慢速提踵的价值在于控制质量，不在于做得快。"),
            ("动作安全", "出现不稳、锐痛或麻木时停止当前动作，恢复后再逐步增加范围。")
        ]
    }
    #endif

    @ViewBuilder
    private var dashboard: some View {
        #if os(macOS)
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top, spacing: 24) {
                VStack(spacing: 20) {
                    todayPlan
                    if !isStrengthSession { repair }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                VStack(spacing: 20) {
                    readiness
                    calendar
                    if isStrengthSession { repair }
                }
                .frame(width: 440, alignment: .top)
            }
        }
        #endif
    }

    private var isStrengthSession: Bool {
        store.currentSession == .strengthA || store.currentSession == .strengthB
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date.now.formatted(.dateTime.locale(Locale(identifier: "zh_CN")).month(.wide).day().weekday(.wide)))
                    .font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                Text("练得刚好")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
            }
            Spacer()
            #if os(macOS)
            Button { showSettings = true } label: { Image(systemName: "gearshape") }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 10))
            #endif
        }
        .padding(.bottom, 2)
    }

    private var readiness: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("每日状态")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color(red: 0.05, green: 0.36, blue: 0.29))
            Text("今天身体感觉如何？")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color(red: 0.04, green: 0.18, blue: 0.14))
            HStack(spacing: 8) {
                ForEach(["累", "正常", "状态好"], id: \.self) { feeling in
                    let isSelected = store.readiness == feeling
                    Button { store.readiness = feeling } label: {
                        Text(feeling)
                            .font(.subheadline.weight(.bold))
                            .frame(maxWidth: .infinity, minHeight: 42)
                            .foregroundStyle(isSelected ? .white : Color(red: 0.05, green: 0.25, blue: 0.19))
                            .background(isSelected ? Color(red: 0.05, green: 0.42, blue: 0.32) : AppPalette.surface(isNight: store.appearance == .night, opacity: 0.82), in: RoundedRectangle(cornerRadius: 10))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isSelected ? Color.clear : Color(red: 0.05, green: 0.42, blue: 0.32).opacity(0.24), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(store.readiness == "累" ? "今天降低训练量，改恢复日也完全合理。" : store.readiness == "状态好" ? "状态好也不练到力竭。" : "按计划完成，保留 1-2 次余力。")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color(red: 0.12, green: 0.30, blue: 0.24))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(store.appearance == .night ? Color(red: 0.05, green: 0.20, blue: 0.16) : Color(red: 0.87, green: 0.95, blue: 0.90), in: RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .topTrailing) {
            Image(systemName: "heart.text.square.fill")
                .font(.title2)
                .foregroundStyle(Color(red: 0.05, green: 0.42, blue: 0.32))
                .padding(18)
                .accessibilityHidden(true)
        }
    }

    private var calendar: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("训练记录").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            HStack { Text(month.formatted(.dateTime.locale(Locale(identifier: "zh_CN")).year().month(.wide))).font(.title3.bold()); Spacer(); Button { month = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? month } label: { Image(systemName: "chevron.left") }.buttonStyle(.bordered).buttonBorderShape(.circle); Button { month = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? month } label: { Image(systemName: "chevron.right") }.buttonStyle(.bordered).buttonBorderShape(.circle) }
            TrainingCalendar(month: month, completed: store.completed)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(store.appearance == .night ? Color(red: 0.04, green: 0.16, blue: 0.15) : .teal.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    private var todayPlan: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日份额").font(.caption.weight(.heavy)).foregroundStyle(.teal)
                    Text(store.currentSession.rawValue).font(.title.weight(.bold))
                }
                Spacer()
                Button { showResetConfirmation = true } label: { Image(systemName: "arrow.counterclockwise") }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 10))
                    .help("重置今日训练")
                    .accessibilityLabel("重置今日训练")
                Button("切换") { store.cycleSession() }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 10))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(store.appearance == .night ? Color(red: 0.05, green: 0.18, blue: 0.16) : Color(red: 0.88, green: 0.95, blue: 0.92), in: RoundedRectangle(cornerRadius: 16))
            Text(store.currentSession.summary).font(.footnote).foregroundStyle(.secondary)
            ForEach(store.exercises) { exercise in ExerciseRow(exercise: exercise) { selectedExercise = exercise } }
            HStack(spacing: 10) {
                Button(store.isRestingToday ? "恢复今日训练" : (store.isCompleteToday ? "今日已完成" : "完成今日训练")) {
                    if store.isRestingToday { store.resetToday() } else { completeToday() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.isCompleteToday && !store.isRestingToday)
                .frame(maxWidth: .infinity)
                .tint(store.isRestingToday ? .orange : (store.isCompleteToday ? .green : .teal))
                .scaleEffect(completionPulse ? 1.06 : 1)
                .animation(.spring(response: 0.28, dampingFraction: 0.45), value: completionPulse)

                if !store.isCompleteToday {
                    Button("今日休息", systemImage: "bed.double") { store.restToday() }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                }
            }
        }
    }

    private var repair: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("每日修复").font(.title3.bold())
                Text("5 分钟肩踝保养").font(.footnote).foregroundStyle(.secondary)
            }
            LazyVStack(spacing: 12) {
                ForEach(dailyRepair) { exercise in ExerciseRow(exercise: exercise) { selectedExercise = exercise } }
            }
        }
    }

    private var settingsHub: some View {
        Button {
            showSettings = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundStyle(.teal)
                    .frame(width: 34, height: 34)
                    .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 3) {
                    Text("外观、提醒与主页内容")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("背景照片、晚上版、每日内容和提醒")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .background(AppPalette.surface(isNight: store.appearance == .night, opacity: 0.88), in: RoundedRectangle(cornerRadius: 16))
        .overlay { RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(store.appearance == .night ? 0.12 : 0.65), lineWidth: 1) }
    }

    private func completeToday() {
        guard !store.isCompleteToday else { return }
        store.completeToday()
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
        withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
            completionPulse = true
            showCompletionToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            completionPulse = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { showCompletionToast = false }
        }
    }
}

private enum AppPalette {
    static func surface(isNight: Bool, opacity: Double = 1) -> Color {
        let color = isNight ? Color(red: 0.07, green: 0.09, blue: 0.09) : .white
        return color.opacity(opacity)
    }
}

private struct AppPhotoBackground: View {
    @EnvironmentObject private var store: TrainingStore
    let isVisible: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                store.appearance == .night ? Color.black : Color.white
                if isVisible, let data = store.backgroundImageData, let image = backgroundImage(data) {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .opacity(store.backgroundImageOpacity)
                        .overlay(Color.black.opacity(store.appearance == .night ? 0.28 : 0.05))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
    }

    private func backgroundImage(_ data: Data) -> Image? {
        #if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        return Image(uiImage: image)
        #elseif canImport(AppKit)
        guard let image = NSImage(data: data) else { return nil }
        return Image(nsImage: image)
        #endif
    }
}

private struct SettingsView: View {
    @EnvironmentObject private var store: TrainingStore
    @Environment(\.dismiss) private var dismiss
    @State private var reminderGranted = false
    @State private var selectedBackgroundPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section("每日提醒") {
                    Stepper("提醒时间：\(store.reminderHour):00", value: $store.reminderHour, in: 6...23)
                    Button(store.reminderEnabled ? "更新提醒" : "开启每日提醒") { Task { reminderGranted = await store.requestReminder(); await store.scheduleReminder() } }
                    if reminderGranted { Text("已请求系统通知权限。") .font(.footnote).foregroundStyle(.secondary) }
                }
                Section("主页每日内容") {
                    Picker("显示内容", selection: $store.dailyHomeContent) {
                        ForEach(DailyHomeContent.allCases) { content in
                            Text(content.rawValue).tag(content)
                        }
                    }
                    Text("每日内容会随日期轮换。经典语句均标明原典出处。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("界面预设") {
                    Picker("配色", selection: $store.appearance) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.rawValue).tag(appearance)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text("晚上版会使用深色背景和低亮度训练卡片，适合夜间查看。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("界面背景") {
                    PhotosPicker(selection: $selectedBackgroundPhoto, matching: .images) {
                        Label("选择或更换背景照片", systemImage: "photo.on.rectangle")
                    }
                    if store.backgroundImageData != nil {
                        Label("背景照片已启用", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Toggle("所有页面使用背景照片", isOn: $store.backgroundAppliesToAllPages)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("照片强度")
                            Slider(value: $store.backgroundImageOpacity, in: 0.12...0.62, step: 0.02)
                        }
                        Button("恢复默认背景", role: .destructive) { store.removeBackgroundImage() }
                    }
                    Text("照片会作为整页底层背景。训练文字和按钮仍保留浅色底，确保使用时清晰。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("设置")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { store.saveSettings(); dismiss() } } }
            .task(id: selectedBackgroundPhoto) {
                guard let selectedBackgroundPhoto,
                      let data = try? await selectedBackgroundPhoto.loadTransferable(type: Data.self) else { return }
                store.setBackgroundImage(data)
            }
        }
        .preferredColorScheme(store.appearance.colorScheme)
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise
    let action: () -> Void
    @EnvironmentObject private var store: TrainingStore
    @State private var showTimer = false
    @State private var showStatusFeedback = false
    @State private var showRestSheet = false
    private var completeCount: Int { (0..<exercise.setCount).filter { store.isSetComplete($0, for: exercise) }.count }
    private var nextSet: Int? { (0..<exercise.setCount).first { !store.isSetComplete($0, for: exercise) } }
    private var isSingleTask: Bool { exercise.setCount == 1 }
    private var restReason: String? { store.isResting(exercise) }
    private var isCapped: Bool { store.isCapped(exercise) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(exercise.name).fontWeight(.semibold)
                    if completeCount == exercise.setCount {
                        Label("完成", systemImage: "checkmark.seal.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                            .transition(.scale.combined(with: .opacity))
                    }
                    Spacer(minLength: 0)
                    if completeCount > 0 {
                        Button { store.reset(exercise) } label: { Image(systemName: "arrow.counterclockwise") }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.circle)
                            .controlSize(.small)
                            .tint(.secondary)
                            .help("重置本动作")
                            .accessibilityLabel("重置 \(exercise.name)")
                    }
                    Button(action: action) { Image(systemName: "photo") }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .controlSize(.small)
                        .accessibilityLabel("查看 \(exercise.name) 图文指导")
                }

                Text(exercise.purpose)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.teal)

                Text(exercise.dose).font(.caption).foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Text(restReason != nil ? "本动作休息" : (isCapped ? "已达上限" : (isSingleTask ? (completeCount == 1 ? "已完成" : "待开始") : "\(completeCount) / \(exercise.setCount) 组")))
                        .font(.caption.bold())
                        .foregroundStyle(restReason != nil ? .orange : (isCapped ? .yellow : (completeCount == exercise.setCount ? .green : .secondary)))
                    if let restReason {
                        Text("\(restReason)未恢复")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    } else if exercise.isPerSide && completeCount < exercise.setCount && !isCapped {
                        Text("下一项：\(nextSet.map(exercise.completionLabel(for:)) ?? "")")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                if !isSingleTask {
                    ProgressView(value: Double(completeCount), total: Double(exercise.setCount))
                        .tint(isCapped ? .yellow : (restReason != nil ? .orange : (completeCount == exercise.setCount ? .green : .accentColor)))
                }

                HStack(spacing: 8) {
                    if exercise.timerSeconds != nil {
                        Button { showTimer = true } label: {
                            Image(systemName: "timer")
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .controlSize(.small)
                        .help("计时")
                        .accessibilityLabel("\(exercise.name)计时")
                    }

                    if restReason != nil || isCapped {
                        Button {
                            store.resume(exercise)
                        } label: {
                            Label(restReason != nil ? "恢复动作" : "恢复进度", systemImage: "arrow.clockwise")
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(restReason != nil ? .orange : .yellow)
                        .frame(maxWidth: .infinity)
                    } else if let nextSet {
                        Button {
                            toggle(nextSet, wasDone: false)
                        } label: {
                            Text(isSingleTask ? "完成本动作" : "完成\(exercise.completionLabel(for: nextSet))")
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .frame(maxWidth: .infinity)
                    } else {
                        Label("本动作完成", systemImage: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        showStatusFeedback = true
                    } label: {
                        Image(systemName: "heart.text.square")
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .controlSize(.small)
                    .tint(.teal)
                    .help("状态反馈")
                    .accessibilityLabel("\(exercise.name)状态反馈")

                    Button {
                        showRestSheet = true
                    } label: {
                        Image(systemName: "bed.double")
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .controlSize(.small)
                    .tint(.orange)
                    .help("本动作休息")
                    .accessibilityLabel("\(exercise.name)休息")
                }
        }
        .padding(14)
        .background(AppPalette.surface(isNight: store.appearance == .night, opacity: store.backgroundImageData == nil ? 1 : 0.88), in: RoundedRectangle(cornerRadius: 14))
        .overlay { RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(store.backgroundImageData == nil ? 0.2 : 0.68), lineWidth: 1) }
        .animation(.spring(response: 0.32, dampingFraction: 0.7), value: completeCount)
        .sheet(isPresented: $showTimer) {
            if let seconds = exercise.timerSeconds {
                ExerciseTimer(exercise: exercise, seconds: seconds, stepLabel: nextSet.map(exercise.completionLabel(for:)) ?? "本动作") {
                    if let nextSet { toggle(nextSet, wasDone: false) }
                }
            }
        }
        .sheet(isPresented: $showStatusFeedback) {
            ExerciseStatusFeedback(exercise: exercise, completedSets: completeCount) {
                store.cap(exercise)
            }
        }
        .sheet(isPresented: $showRestSheet) {
            ExerciseRestSheet(exercise: exercise) { reason in
                store.rest(exercise, reason: reason)
            }
        }
    }

    private func toggle(_ index: Int, wasDone: Bool) {
        store.toggleSet(index, for: exercise)
        #if canImport(UIKit)
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(wasDone ? .warning : .success)
        #endif
    }
}

private struct ExerciseStatusFeedback: View {
    let exercise: Exercise
    let completedSets: Int
    let onCap: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var advice: String?

    private var prompt: String {
        if isLowerBody { return "关注腿部用力、膝盖与脚踝的感受。" }
        if exercise.name.contains("俯卧撑") { return "关注胸臂疲劳，以及肩膀和手腕的承受感。" }
        if exercise.name.contains("臀桥") { return "臀部应主导发力，腰部不应成为主要压力点。" }
        if isCore { return "核心动作以稳定躯干为先，不靠憋气或硬撑。" }
        if isShoulderControl { return "肩胛控制应平稳，颈部不应代偿用力。" }
        if isAnkleOrCalf { return "关注小腿疲劳与脚踝稳定，不追求极限幅度。" }
        if exercise.name.contains("跑") || exercise.name.contains("走") { return "先看呼吸、步态和下肢是否稳定。" }
        if exercise.name.contains("呼吸") { return "呼吸放松应舒适、自然，不应憋气或头晕。" }
        return "根据动作控制感与身体反应决定下一步。"
    }

    private var isLowerBody: Bool { ["深蹲", "箭步", "静蹲"].contains { exercise.name.contains($0) } }
    private var isCore: Bool { ["死虫", "侧桥", "平板"].contains { exercise.name.contains($0) } }
    private var isShoulderControl: Bool { ["滑手", "Y-T", "肩胛"].contains { exercise.name.contains($0) } }
    private var isAnkleOrCalf: Bool { ["提踵", "小腿", "踝", "单脚"].contains { exercise.name.contains($0) } }
    private var baseSignals: [(title: String, icon: String, advice: String)] {
        if isLowerBody { return [("腿部发紧", "figure.strengthtraining.traditional", "休息 60-90 秒。下一组减少 2-4 次或缩短下蹲幅度；后撤箭步蹲仍紧时改为 2 组即可。"), ("膝踝不适", "exclamationmark.triangle", "停止该动作，改为无痛范围的轻松走动或结束下肢训练；症状持续、肿胀或影响走路时咨询专业人士。"), ("腿软了", "figure.walk", "结束该动作，今天不再补组。")] }
        if exercise.name.contains("俯卧撑") { return [("胸臂疲劳", "figure.strengthtraining.traditional", "休息 60-90 秒；下一组降低次数或提高支撑面，不必补足原计划。"), ("肩腕不适", "exclamationmark.triangle", "停止该动作；可改为墙面肩胛俯卧撑。疼痛持续或影响日常活动时咨询专业人士。"), ("手臂先力竭", "arm.flex", "下一组提高支撑面并减少次数。")] }
        if exercise.name.contains("臀桥") { return [("臀腿疲劳", "figure.strengthtraining.traditional", "休息 60 秒，下一组减少次数或改回双腿臀桥，保持动作范围可控。"), ("腰部不适", "exclamationmark.triangle", "停止该动作，降低抬髋高度；当次不要继续加量，持续不适时咨询专业人士。"), ("后侧大腿抢力", "arrow.down.right.and.arrow.up.left", "降低抬髋高度，下一组减少次数。")] }
        if isCore { return [("腹部疲劳", "figure.core.training", "休息 45-60 秒，下一组缩短时间或减小手脚伸展范围。"), ("腰肩不适", "exclamationmark.triangle", "停止该动作；死虫式缩小范围，桥式动作可改屈膝版本。持续不适时咨询专业人士。"), ("呼吸憋住", "lungs", "结束当前组，恢复自然呼吸。")] }
        if isShoulderControl { return [("肩胛疲劳", "figure.flexibility", "休息 45-60 秒，下一组减小抬举幅度或次数。"), ("肩颈不适", "exclamationmark.triangle", "停止该动作，放松后仅在无痛范围活动；症状持续时咨询专业人士。"), ("颈部代偿", "figure.flexibility", "降低手臂高度。")] }
        if isAnkleOrCalf { return [("小腿疲劳", "figure.walk", "休息 45-60 秒，下一组减少次数或幅度，慢慢下放。"), ("脚踝不适", "exclamationmark.triangle", "停止该动作，避免继续单脚负重；症状持续或加重时咨询专业人士。"), ("抽筋趋势", "bolt", "停止该组，轻柔活动脚踝并补水。")] }
        if exercise.name.contains("跑") || exercise.name.contains("走") { return [("呼吸偏急", "lungs", "降低为快走，直到呼吸恢复；下一轮缩短跑段或减少轮数。"), ("下肢不适", "exclamationmark.triangle", "当次改为轻松走或结束训练；肿胀、持续疼痛或影响走路时咨询专业人士。"), ("步伐变重", "figure.walk", "当次改为轻松走。")] }
        if exercise.name.contains("呼吸") { return [("难以放松", "wind", "缩短到 1 分钟，恢复自然呼吸，不必刻意深吸。"), ("头晕不适", "exclamationmark.triangle", "停止练习，坐下或侧卧休息；症状持续或严重时寻求专业帮助。"), ("呼吸过深", "wind", "恢复平常呼吸。")] }
        return [("局部疲劳", "figure.strengthtraining.traditional", "休息 45-60 秒，下一组减少次数或幅度。"), ("疼痛或不稳", "exclamationmark.triangle", "停止该动作；症状持续或影响日常活动时咨询专业人士。"), ("呼吸乱了", "wind", "休息 45-60 秒，先恢复可控呼吸。")]
    }

    private var signals: [(title: String, icon: String, advice: String)] {
        var items = baseSignals
        let followUp: (title: String, icon: String, advice: String)
        if isLowerBody { followUp = ("腿软了", "figure.walk", "结束该动作，今天不再补组；轻松走动并补水，恢复后再继续下肢训练。") }
        else if exercise.name.contains("俯卧撑") { followUp = ("手臂先力竭", "arm.flex", "下一组提高支撑面并减少次数，身体保持直线；不必硬撑完成原次数。") }
        else if exercise.name.contains("臀桥") { followUp = ("后侧大腿抢力", "arrow.down.right.and.arrow.up.left", "把脚跟略靠近臀部，降低抬髋高度；下一组减少次数。") }
        else if isCore { followUp = ("呼吸憋住", "lungs", "结束当前组，恢复自然呼吸；下一组缩短时间或减小范围。") }
        else if isShoulderControl { followUp = ("颈部代偿", "figure.flexibility", "降低手臂高度，先放松肩膀；下一组只做无颈部紧张的范围。") }
        else if isAnkleOrCalf { followUp = ("抽筋趋势", "bolt", "停止该组，轻柔活动脚踝并补水；当天不要继续增加提踵或跑量。") }
        else if exercise.name.contains("跑") || exercise.name.contains("走") { followUp = ("步伐变重", "figure.walk", "当次改为轻松走，缩短下一跑段或提前结束训练。") }
        else if exercise.name.contains("呼吸") { followUp = ("呼吸过深", "wind", "恢复平常呼吸，不要强行深吸；不适持续则停止练习。") }
        else { followUp = ("呼吸乱了", "wind", "休息 45-60 秒，下一组减小次数或幅度，先恢复可控呼吸。") }
        items[2] = followUp
        return items
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(prompt).font(.subheadline).foregroundStyle(.secondary)
                if let advice {
                    Text(advice)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(.mint.opacity(0.16), in: RoundedRectangle(cornerRadius: 10))
                } else {
                    ForEach(Array(signals.enumerated()), id: \.offset) { index, signal in
                        Button(signal.title, systemImage: signal.icon) {
                            advice = signal.advice
                            if index == 0 || (isLowerBody && index == 2) { onCap() }
                        }
                            .buttonStyle(.bordered)
                            .tint(signal.icon == "exclamationmark.triangle" ? .orange : .teal)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("动作状态反馈")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } }
        }
        .presentationDetents([.medium])
    }
}

private struct ExerciseRestSheet: View {
    let exercise: Exercise
    let rest: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private var bodyParts: [(name: String, icon: String)] {
        if isLowerBody { return [("大腿或臀部", "figure.strengthtraining.traditional"), ("膝盖", "figure.walk"), ("脚踝", "figure.walk")]
        }
        if exercise.name.contains("俯卧撑") { return [("胸臂", "arm.flex"), ("肩膀", "figure.flexibility"), ("手腕", "hand.raised")]
        }
        if exercise.name.contains("臀桥") { return [("臀部", "figure.strengthtraining.traditional"), ("后侧大腿", "figure.walk"), ("腰部", "figure.core.training")]
        }
        if isCore { return [("腹部", "figure.core.training"), ("腰部", "figure.core.training"), ("肩部", "figure.flexibility")]
        }
        if isShoulderControl { return [("肩胛", "figure.flexibility"), ("肩膀", "figure.flexibility"), ("颈部", "figure.flexibility")]
        }
        if isAnkleOrCalf { return [("小腿", "figure.walk"), ("脚踝", "figure.walk"), ("足部", "figure.walk")]
        }
        if exercise.name.contains("跑") || exercise.name.contains("走") { return [("呼吸恢复", "lungs"), ("膝盖", "figure.walk"), ("脚踝或足部", "figure.walk")]
        }
        if exercise.name.contains("呼吸") { return [("呼吸节奏", "wind"), ("胸口不适", "lungs"), ("头晕", "exclamationmark.triangle")]
        }
        return [("局部肌肉", "figure.strengthtraining.traditional"), ("关节", "figure.walk"), ("整体疲劳", "bed.double")]
    }

    private var isLowerBody: Bool { ["深蹲", "箭步", "静蹲"].contains { exercise.name.contains($0) } }
    private var isCore: Bool { ["死虫", "侧桥", "平板"].contains { exercise.name.contains($0) } }
    private var isShoulderControl: Bool { ["滑手", "Y-T", "肩胛"].contains { exercise.name.contains($0) } }
    private var isAnkleOrCalf: Bool { ["提踵", "小腿", "踝", "单脚"].contains { exercise.name.contains($0) } }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("选择尚未恢复的部位，剩余组数会暂停。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(Array(bodyParts.enumerated()), id: \.offset) { _, part in
                    Button(part.name, systemImage: part.icon) {
                        rest(part.name)
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("本动作休息")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } } }
        }
        .presentationDetents([.medium])
    }
}

private struct ExerciseTimer: View {
    let exercise: Exercise
    let seconds: Int
    let stepLabel: String
    let complete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var remaining: Int
    @State private var isRunning = false
    @State private var hasFinished = false
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(exercise: Exercise, seconds: Int, stepLabel: String, complete: @escaping () -> Void) {
        self.exercise = exercise
        self.seconds = seconds
        self.stepLabel = stepLabel
        self.complete = complete
        _remaining = State(initialValue: seconds)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: hasFinished ? "checkmark.circle.fill" : "timer")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundStyle(hasFinished ? .green : .teal)

                VStack(spacing: 6) {
                    Text(exercise.name).font(.title3.weight(.bold))
                    Text("目标 \(formatted(seconds)) · \(stepLabel)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(formatted(remaining))
                    .font(.system(size: 62, weight: .semibold, design: .rounded).monospacedDigit())
                    .contentTransition(.numericText())
                    .foregroundStyle(hasFinished ? .green : .primary)

                HStack(spacing: 12) {
                    Button { reset() } label: { Image(systemName: "arrow.counterclockwise") }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .accessibilityLabel("重置计时")

                    Button { isRunning.toggle() } label: {
                        Label(isRunning ? "暂停" : (remaining == seconds ? "开始" : "继续"), systemImage: isRunning ? "pause.fill" : "play.fill")
                            .frame(minWidth: 112)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                    .disabled(hasFinished)
                }

                Button("计时结束，标记\(stepLabel)完成") {
                    complete()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(!hasFinished)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .navigationTitle("训练计时")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("关闭") { dismiss() } } }
        }
        .onReceive(ticker) { _ in
            guard isRunning, remaining > 0 else { return }
            remaining -= 1
            if remaining == 0 {
                isRunning = false
                hasFinished = true
                #if canImport(UIKit)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                #endif
            }
        }
    }

    private func reset() {
        remaining = seconds
        isRunning = false
        hasFinished = false
    }

    private func formatted(_ duration: Int) -> String {
        String(format: "%02d:%02d", duration / 60, duration % 60)
    }
}
