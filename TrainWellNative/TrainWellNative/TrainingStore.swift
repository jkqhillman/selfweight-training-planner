import Foundation
import UserNotifications

@MainActor
final class TrainingStore: ObservableObject {
    @Published var currentSession: SessionKind
    @Published private(set) var completed: [Date: SessionKind]
    @Published var readiness = "正常"
    @Published var reminderEnabled = false
    @Published var reminderHour = 19
    @Published var dailyHomeContent: DailyHomeContent
    @Published var appearance: AppAppearance
    @Published private(set) var backgroundImageData: Data?
    @Published var backgroundImageOpacity: Double
    @Published var backgroundAppliesToAllPages: Bool
    @Published private var setChecks: [String: [Int]]
    @Published private var restedExercises: [String: String]
    @Published private var cappedExercises: Set<String>

    private let defaults = UserDefaults.standard
    private let sessionKey = "native.currentSession"
    private let recordsKey = "native.completedRecords"
    private let dailyHomeContentKey = "native.dailyHomeContent"
    private let appearanceKey = "native.appearance"
    private let setChecksKey = "native.setChecks"
    private let backgroundOpacityKey = "native.backgroundOpacity"
    private let backgroundAllPagesKey = "native.backgroundAllPages"
    private let restedExercisesKey = "native.restedExercises"
    private let cappedExercisesKey = "native.cappedExercises"

    init() {
        let storedSession = defaults.string(forKey: sessionKey).flatMap(SessionKind.init(rawValue:))
        let records = Self.decodeRecords(defaults.data(forKey: recordsKey))
        self.completed = records
        self.currentSession = storedSession ?? Self.nextStrengthSession(records) ?? .strengthA
        self.dailyHomeContent = defaults.string(forKey: dailyHomeContentKey).flatMap(DailyHomeContent.init(rawValue:)) ?? .classicQuote
        self.appearance = defaults.string(forKey: appearanceKey).flatMap(AppAppearance.init(rawValue:)) ?? .day
        self.backgroundImageData = Self.loadBackgroundImage()
        let savedOpacity = defaults.object(forKey: backgroundOpacityKey) as? Double
        self.backgroundImageOpacity = savedOpacity ?? 0.30
        self.backgroundAppliesToAllPages = defaults.object(forKey: backgroundAllPagesKey) as? Bool ?? true
        self.setChecks = (try? JSONDecoder().decode([String: [Int]].self, from: defaults.data(forKey: setChecksKey) ?? Data())) ?? [:]
        self.restedExercises = (try? JSONDecoder().decode([String: String].self, from: defaults.data(forKey: restedExercisesKey) ?? Data())) ?? [:]
        self.cappedExercises = Set((try? JSONDecoder().decode([String].self, from: defaults.data(forKey: cappedExercisesKey) ?? Data())) ?? [])
        autoCompleteIfReady()
    }

    var today: Date { Calendar.current.startOfDay(for: .now) }
    var isCompleteToday: Bool { completed[today] != nil }
    var isRestingToday: Bool { completed[today] == .recovery }
    var exercises: [Exercise] { trainingPlans[currentSession] ?? [] }

    private var allCurrentExercisesComplete: Bool {
        !exercises.isEmpty && exercises.allSatisfy { exercise in
            isResting(exercise) == nil && !isCapped(exercise) && (0..<exercise.setCount).allSatisfy { isSetComplete($0, for: exercise) }
        }
    }

    private func autoCompleteIfReady() {
        guard !isCompleteToday, allCurrentExercisesComplete else { return }
        completed[today] = currentSession
        save()
    }

    func isSetComplete(_ index: Int, for exercise: Exercise) -> Bool { setChecks[setKey(exercise), default: []].contains(index) }
    func toggleSet(_ index: Int, for exercise: Exercise) {
        let key = setKey(exercise)
        guard restedExercises[key] == nil, !cappedExercises.contains(key) else { return }
        var checked = setChecks[key, default: []]
        checked = checked.contains(index) ? checked.filter { $0 != index } : (checked + [index]).sorted()
        setChecks[key] = checked
        defaults.set(try? JSONEncoder().encode(setChecks), forKey: setChecksKey)
        autoCompleteIfReady()
    }

    func cycleSession() {
        let sessions = SessionKind.allCases
        guard let index = sessions.firstIndex(of: currentSession) else { return }
        currentSession = sessions[(index + 1) % sessions.count]
        save()
    }

    func completeToday() {
        completed[today] = currentSession
        save()
    }

    func resetToday() {
        completed[today] = nil
        let prefix = "\(today.timeIntervalSince1970)|"
        setChecks = setChecks.filter { !$0.key.hasPrefix(prefix) }
        defaults.set(try? JSONEncoder().encode(setChecks), forKey: setChecksKey)
        restedExercises = restedExercises.filter { !$0.key.hasPrefix(prefix) }
        cappedExercises = Set(cappedExercises.filter { !$0.hasPrefix(prefix) })
        persistLimits()
        save()
    }

    func reset(_ exercise: Exercise) {
        let key = setKey(exercise)
        setChecks[key] = nil
        defaults.set(try? JSONEncoder().encode(setChecks), forKey: setChecksKey)
        restedExercises[key] = nil
        cappedExercises.remove(key)
        persistLimits()
    }
    func isResting(_ exercise: Exercise) -> String? { restedExercises[setKey(exercise)] }
    func isCapped(_ exercise: Exercise) -> Bool { cappedExercises.contains(setKey(exercise)) }
    func rest(_ exercise: Exercise, reason: String) { restedExercises[setKey(exercise)] = reason; persistLimits() }
    func cap(_ exercise: Exercise) { cappedExercises.insert(setKey(exercise)); persistLimits() }
    func resume(_ exercise: Exercise) { restedExercises[setKey(exercise)] = nil; cappedExercises.remove(setKey(exercise)); persistLimits() }
    func restToday() { completed[today] = .recovery; save() }

    func saveSettings() {
        defaults.set(dailyHomeContent.rawValue, forKey: dailyHomeContentKey)
        defaults.set(appearance.rawValue, forKey: appearanceKey)
        defaults.set(backgroundImageOpacity, forKey: backgroundOpacityKey)
        defaults.set(backgroundAppliesToAllPages, forKey: backgroundAllPagesKey)
        save()
    }

    func setBackgroundImage(_ data: Data) {
        guard let url = Self.backgroundImageURL else { return }
        do {
            try data.write(to: url, options: .atomic)
            backgroundImageData = data
        } catch { }
    }

    func removeBackgroundImage() {
        backgroundImageData = nil
        guard let url = Self.backgroundImageURL else { return }
        try? FileManager.default.removeItem(at: url)
    }

    func requestReminder() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            guard granted else { return false }
            reminderEnabled = true
            await scheduleReminder()
            return true
        } catch { return false }
    }

    func scheduleReminder() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily-training-reminder"])
        guard reminderEnabled else { return }
        var components = DateComponents()
        components.hour = reminderHour
        let content = UNMutableNotificationContent()
        content.title = "今天的训练份额"
        content.body = "\(currentSession.rawValue)：\(currentSession.summary)"
        content.sound = .default
        let request = UNNotificationRequest(identifier: "daily-training-reminder", content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true))
        try? await center.add(request)
    }

    private func save() {
        defaults.set(currentSession.rawValue, forKey: sessionKey)
        defaults.set(Self.encodeRecords(completed), forKey: recordsKey)
    }
    private func persistLimits() { defaults.set(try? JSONEncoder().encode(restedExercises), forKey: restedExercisesKey); defaults.set(try? JSONEncoder().encode(Array(cappedExercises)), forKey: cappedExercisesKey) }

    private func setKey(_ exercise: Exercise) -> String {
        switch exercise.progressScope {
        case .plan:
            return "\(today.timeIntervalSince1970)|\(currentSession.rawValue)|\(exercise.id)"
        case .recovery:
            return "\(today.timeIntervalSince1970)|recovery|\(exercise.id)"
        }
    }

    private static func nextStrengthSession(_ records: [Date: SessionKind]) -> SessionKind? {
        let last = records.sorted { $0.key < $1.key }.last(where: { $0.value == .strengthA || $0.value == .strengthB })?.value
        return last == .strengthA ? .strengthB : last == .strengthB ? .strengthA : nil
    }

    private static func encodeRecords(_ records: [Date: SessionKind]) -> Data? {
        let mapped = records.map { ["date": ISO8601DateFormatter().string(from: $0.key), "session": $0.value.rawValue] }
        return try? JSONSerialization.data(withJSONObject: mapped)
    }

    private static func decodeRecords(_ data: Data?) -> [Date: SessionKind] {
        guard let data, let rows = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] else { return [:] }
        let formatter = ISO8601DateFormatter()
        return rows.reduce(into: [:]) { result, row in
            guard let raw = row["session"], let session = SessionKind(rawValue: raw), let dateString = row["date"], let date = formatter.date(from: dateString) else { return }
            result[Calendar.current.startOfDay(for: date)] = session
        }
    }

    private static var backgroundImageURL: URL? {
        guard let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("training-background-image")
    }

    private static func loadBackgroundImage() -> Data? {
        guard let url = backgroundImageURL else { return nil }
        return try? Data(contentsOf: url)
    }
}
